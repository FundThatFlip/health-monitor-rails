# frozen_string_literal: true

require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class DatabaseException < StandardError; end

    class Database < Base
      class Configuration
        include SharedConfiguration
      end

      def check!
        # Check connection to the DB:
        ActiveRecord::Migrator.current_version
      rescue Exception => e
        raise DatabaseException.new(e.message)
      end

      private

      class << self
        private

        def configuration_class
          ::HealthMonitor::Providers::Database::Configuration
        end
      end
    end
  end
end
