# frozen_string_literal: true

require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class DatabaseException < StandardError; end

    class Database < Base
      class Configuration
        def cache_interval=(value)
          HealthMonitor::Providers::Database.cache_interval value
        end
      end

      def check!
        failed_databases = []

        ActiveRecord::Base.connection_handler.all_connection_pools.each do |cp|
          cp.connection.check_version
        rescue Exception
          failed_databases << cp.db_config.name
        end

        raise "unable to connect to: #{failed_databases.uniq.join(',')}" unless failed_databases.empty?
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
