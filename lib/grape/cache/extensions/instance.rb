# frozen_string_literal: true

module Grape
  module Cache
    module Extensions
      # @nodoc
      module Instance
        extend ActiveSupport::Concern

        class_methods do
          # @param context [Grape::Cache::DSL] cache instance created in `cache` block
          # @return [Proc] route proc with caching logic
          def generate_cached_api_method(context, &block) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
            return block unless context

            proc do
              header 'Cache-Control', context[:cache_control]

              key = context[:key]
              key = key.is_a?(Proc) ? instance_exec(&key) : key
              key = Grape::Cache::Helpers.expand_cache_key(env, *key)

              cached_response = Grape::Cache.read(key)
              (cached_response || instance_exec(&block)).tap do |response|
                env['grape-cache'] = {
                  key: key,
                  value: response,
                  exists: !cached_response.nil?,
                  options: context.slice(:expires_in, :race_condition_ttl).compact
                }
              end
            end
          end

          # @api private
          def route(*args, &block)
            super(*args, &generate_cached_api_method(route_setting(:cache), &block))
          end
        end
      end
    end
  end
end