# frozen_string_literal: true

require 'health_monitor/providers/base'
require 'resque'

module HealthMonitor
  module Providers
    class ResqueException < StandardError; end

    class Resque < Base
      class Configuration
        include SharedConfiguration
      end

      def check!
        ::Resque.info
      rescue Exception => e
        raise ResqueException.new(e.message)
      end

      private

      class << self
        private

        def configuration_class
          ::HealthMonitor::Providers::Resque::Configuration
        end
      end
    end
  end
end
