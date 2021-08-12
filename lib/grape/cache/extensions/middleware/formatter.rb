# frozen_string_literal: true

module Grape
  module Cache
    module Extensions
      module Middleware
        # @nodoc
        module Formatter
          def fetch_formatter(*)
            formatter = super

            lambda do |body, env|
              cache = env['grape-cache']

              return formatter.call(body, env) unless cache
              return cache[:value] if cache[:hit]

              formatter.call(body, env).tap do |response|
                Grape::Cache.write(cache[:key], response, cache[:options])
              end
            end
          end
        end
      end
    end
  end
end
