
module HealthMonitor
  module Providers
    module SharedConfiguration
      def self.included(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
      end

      module ClassMethods
      end

      module InstanceMethods
        def cache_interval=(value)
          self.class.name.deconstantize.constantize.cache_interval = value
        end

        def critical=(bool)
          self.class.name.deconstantize.constantize.critical = bool
        end
      end
    end
  end
end
