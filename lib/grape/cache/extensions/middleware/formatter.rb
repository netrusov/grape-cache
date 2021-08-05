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
              context = env['grape-cache']

              return formatter.call(body, env) unless context
              return context[:value] if context[:exists]

              formatter.call(body, env).tap do |response|
                Grape::Cache.store(context[:key], response, **context[:options])
              end
            end
          end
        end
      end
    end
  end
end
