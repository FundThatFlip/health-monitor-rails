# TODO remove
require "pry"
require "pry-nav"

# TODO: rename ProviderCache
#       rename configuration.provider_cache -> configuration.provider_cache_instance
module Cache
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    @cache_interval = nil
    @cache_key = nil
    @cachable = nil

    def cache_interval(value)
      @cache_interval ||= value
    end

    def get_cache_interval
      @cache_interval
    end

    def cache_key
      @cache_key ||= "#{provider_name.downcase}_result"
    end

    def cachable?
      @cachable ||= HealthMonitor.configuration.provider_cache && @cache_interval
    end
  end
end
