# frozen_string_literal: true

require 'active_support/concern'

require 'grape/cache/dsl/context'

module Grape
  module Cache
    module DSL
      extend ActiveSupport::Concern

      class_methods do
        # Evaluate DSL and assign [Grape::Cache::DSL::Context] instance to `:cache` route setting
        #
        # @return [void]
        def cache(&block)
          Grape::Cache::DSL::Context.new.then do |context|
            context.instance_eval(&block)
            route_setting :cache, context
          end
        end
      end
    end
  end
end
