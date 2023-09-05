# frozen_string_literal: true

HealthMonitor::Engine.routes.draw do
  path =
    if HealthMonitor.configuration.path.present?
      HealthMonitor.configuration.path
    else
      :check
    end

  get path, to: 'health#check'

  get '_trusted/print/debug/request', to: 'health#print'
end
