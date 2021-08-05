# frozen_string_literal: true

require 'active_support/concern'

require 'grape/cache/dsl'

module Grape
  module Cache
    module Extensions
      # @nodoc
      module DSL
        extend ActiveSupport::Concern

        class_methods do
          # Evaluate DSL and assign [Grape::Cache::DSL] instance to `:cache` route setting
          #
          # @return [void]
          def cache(&block)
            context = Grape::Cache::DSL.new
            context.instance_exec(&block)
            route_setting(:cache, context)
          end
        end
      end
    end
  end
end
