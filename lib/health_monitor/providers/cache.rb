# frozen_string_literal: true

require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class CacheException < StandardError; end

    class Cache < Base
      class Configuration
        def cache_interval=(value)
          HealthMonitor::Providers::Cache.cache_interval value
        end
      end

      def check!
        time = Time.now.to_s

        Rails.cache.write(key, time)
        fetched = Rails.cache.read(key)

        raise "different values (now: #{time}, fetched: #{fetched})" if fetched != time
      rescue Exception => e
        raise CacheException.new(e.message)
      end

      private

      class << self
        private

        def configuration_class
          ::HealthMonitor::Providers::Cache::Configuration
        end
      end

      def key
        @key ||= ['health', request.try(:remote_ip)].join(':')
      end
    end
  end
end
