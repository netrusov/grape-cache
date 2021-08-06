# frozen_string_literal: true

module Grape
  module Cache
    # @nodoc
    class DSL
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
          [
            (public? ? 'public' : 'private'),
            (no_cache? ? 'no-cache' : "max-age=#{max_age}"),
            ('must-revalidate' if must_revalidate?)
          ].compact.join(', ')
        end
      end

      delegate :[], :slice, to: :@store

      def initialize
        @store = {
          expires_in: 0,
          race_condition_ttl: 5,
          cache_control: 'private, max-age=0, must-revalidate'
        }
      end

      # @return [void]
      def key(value = nil, &block)
        @store[:key] = value || block
      end

      # @param seconds [Integer] cache TTL
      # @return [void]
      def expires_in(seconds)
        @store[:expires_in] = seconds.to_i
      end

      # @param seconds [Integer] cache race condition TTL
      # @return [void]
      def race_condition_ttl(seconds)
        @store[:race_condition_ttl] = seconds.to_i
      end

      # @param options [Hash] parameters for "Cache-Control" header
      # @option options :public [Boolean] defaults to "false"
      # @option options :must_revalidate [Boolean]
      # @option options :max_age [Integer] defaults to "expires_in"
      # @return [void]
      def cache_control(options = {})
        @store[:cache_control] = CacheControl.new(
          options.reverse_merge(max_age: @store[:expires_in])
        ).to_s
      end
    end
  end
end
