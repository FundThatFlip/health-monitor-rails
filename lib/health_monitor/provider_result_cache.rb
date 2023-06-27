# frozen_string_literal: true

module ProviderResultCache
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    @cache_interval = nil
    @cache_key = nil
    @cachable = nil

    def cache_interval=(value)
      @cache_interval ||= value
    end

    def cache_interval
      @cache_interval
    end

    def cache_key
      @cache_key ||= "#{provider_name.downcase}_result"
    end

    def cachable?
      @cachable ||= HealthMonitor.configuration.provider_results_cache && @cache_interval
    end
  end
end
