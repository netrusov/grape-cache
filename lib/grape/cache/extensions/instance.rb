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
          def generate_cached_api_method(context, &block)
            return block unless context

            proc do
              header 'Cache-Control', context[:cache_control]

              key = context[:key]
              key = key.is_a?(Proc) ? instance_exec(&key) : key
              key = Grape::Cache.expand_cache_key(env, key)

              Grape::Cache.with_cached_response(env, key, context) { instance_exec(&block) }
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
