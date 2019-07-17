# frozen_string_literal: true

module Grape
  module Cache
    class Config
      # @private
      class CacheControl
        attr_reader :max_age

        def initialize(max_age, options = {})
          @max_age = max_age
          @options = options
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

      attr_reader :cache_control, :ttl

      @ttl = 0
      @cache_control = 'private, max-age=0, must-revalidate'

      def key(*args, &block)
        if block_given?
          @key = block
        elsif args.present?
          @key = args
        else
          @key
        end
      end

      # @param seconds [Integer] cache TTL
      # @param options [Hash] parameters for `Cache-Control` header
      # @option options [Boolean] :public
      # @option options [Boolean] :must_revalidate
      def expires_in(seconds, options = {})
        @ttl = seconds.to_i
        @cache_control = CacheControl.new(@ttl, options).to_s
      end
    end
  end
end
