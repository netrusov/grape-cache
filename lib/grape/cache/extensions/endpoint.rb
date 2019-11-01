# frozen_string_literal: true

module Grape
  module Cache
    module Extensions
      module Endpoint
        extend ActiveSupport::Concern

        class_methods do
          # @param context [Grape::Cache::DSL::Context] cache instance created in `cache` block
          # @return [Proc] route proc with caching logic
          def generate_cached_api_method(context, &block)
            return block unless context

            proc do
              header 'Cache-Control', context[:cache_control]

              cache_key =
                context[:key]
                  .then { |key| key.is_a?(Proc) ? instance_eval(&key) : key }
                  .then { |key| expand_cache_key(*key) }

              Grape::Cache.read(cache_key) || instance_eval(&block).tap do |response|
                Grape::Cache.store cache_key, (body || response), expires_in: context[:expires_in]
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
