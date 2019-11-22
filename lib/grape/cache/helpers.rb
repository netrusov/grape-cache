# frozen_string_literal: true

require 'active_support/cache'

module Grape
  module Cache
    module Helpers
      # @param *args [String, Integer] parameters which will be concatenated into cache key
      # @return [String] cache key
      def expand_cache_key(*args)
        [
          env.fetch(Rack::REQUEST_METHOD),
          env.fetch(Rack::PATH_INFO),
          '-',
          *args
        ].compact.then(&ActiveSupport::Cache.method(:expand_cache_key))
      end
    end
  end
end
