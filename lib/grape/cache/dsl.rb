# frozen_string_literal: true

module Grape
  module Cache
    module DSL
      # @private
      class CacheControl
        def initialize(options = {})
          @options = options
        end

        def max_age
          @options[:max_age]
        end

        def public?
          @options[:public] && !no_cache?
        end

        def must_revalidate?
          @options[:must_revalidate] || no_cache?
        end

        def no_cache?
          max_age.zero?
        end

        def to_s
          options = []

          options << (public? ? 'public' : 'private')
          options << (no_cache? ? 'no-cache' : ['max-age', max_age].join('='))
          options << 'must-revalidate' if must_revalidate?

          options.join(', ')
        end
      end

      delegate :[], :[]=, :fetch, to: :@storage

      def initialize
        @storage = {
          expires_in: 0,
          cache_control: 'private, max-age=0, must-revalidate'
        }
      end

      # @return [void]
      def key(value = nil, &block)
        self[:key] = value || block
      end

      # @param seconds [Integer] cache TTL
      # @return [void]
      def expires_in(seconds)
        self[:expires_in] = seconds.to_i
      end

      # @param options [Hash] parameters for "Cache-Control" header
      # @option options :public [Boolean] defaults to "false"
      # @option options :must_revalidate [Boolean]
      # @option options :max_age [Integer] defaults to "expires_in"
      # @return [void]
      def cache_control(options = {})
        self[:cache_control] =
          CacheControl.new(options.reverse_merge(max_age: self[:expires_in])).to_s
      end
    end
  end
end
