# frozen_string_literal: true

require 'health_monitor/provider_result_cache'
require 'health_monitor/providers/shared_configuration'

module HealthMonitor
  module Providers
    class Base
      include ProviderResultCache

      DEFAULT_CRITICAL=true

      @global_configuration = nil

      attr_reader :request
      attr_accessor :configuration

      def self.critical
        # memoize boolean
        return @critical if defined? @critical
        @critical = DEFAULT_CRITICAL
      end

      def self.critical=(bool)
        # memoize boolean
        return @critical if defined? @critical
        @critical = bool
      end

      def self.provider_name
        @provider_name ||= name.demodulize
      end

      def self.global_configuration
        @global_configuration ||= configuration_class.new
      end

      def self.configure
        return unless configurable?

        @global_configuration ||= configuration_class.new

        yield @global_configuration if block_given?
      end

      def initialize(request: nil)
        @request = request

        return unless self.class.configurable?

        self.configuration = self.class.global_configuration
      end

      # @abstract
      def check!
        raise NotImplementedError
      end

      def self.configurable?
        configuration_class
      end

      # @abstract
      def self.configuration_class; end
    end
  end
end
