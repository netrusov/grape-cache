# frozen_string_literal: true

require 'active_support/cache'
require 'rack'

module Grape
  module Cache
    # @nodoc
    module Helpers
      module_function

      # @param env [Object] request env
      # @param *args [String, Integer] parameters which will be concatenated into cache key
      # @return [String] cache key
      def expand_cache_key(env, *args)
        keys = [
          env.fetch(Rack::REQUEST_METHOD),
          env.fetch(Rack::PATH_INFO),
          '-',
          *args
        ].compact

        ActiveSupport::Cache.expand_cache_key(keys)
      end
    end
  end
end
