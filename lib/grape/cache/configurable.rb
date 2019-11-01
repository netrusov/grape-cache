# frozen_string_literal: true

require 'active_support/cache'
require 'active_support/concern'

module Grape
  module Cache
    module Configurable
      extend ActiveSupport::Concern

      class Configuration
        attr_accessor :backend

        def initialize
          reset
        end

        def reset
          self.backend = ActiveSupport::Cache::MemoryStore.new
        end
      end

      class_methods do
        def config
          @config ||= Configuration.new
        end

        def configure
          yield config
        end
      end
    end
  end
end
