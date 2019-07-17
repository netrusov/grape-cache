# frozen_string_literal: true

require 'grape/cache/config'

module Grape
  module Cache
    module DSL
      extend ActiveSupport::Concern

      class_methods do
        # Evaluates DSL and assigns [Grape::Cache::Config] instance to ":cache" route setting
        #
        # @return [void]
        def cache(&block)
          Grape::Cache::Config.new.then do |config|
            config.instance_eval(&block)
            route_setting :cache, config
          end
        end

        # @api private
        def route(*args, &block)
          super(*args, &Grape::Cache.generate_route_method(route_setting(:cache), &block))
        end
      end
    end
  end
end
