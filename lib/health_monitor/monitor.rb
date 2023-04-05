# frozen_string_literal: true

require 'health_monitor/configuration'

module HealthMonitor
  STATUSES = {
    ok: 'OK',
    error: 'ERROR'
  }.freeze

  extend self

  attr_accessor :configuration

  def configure
    self.configuration ||= Configuration.new

    yield configuration if block_given?
  end

  def check(request: nil, params: {})
    providers = configuration.providers
    if params[:providers].present?
      providers = providers.select { |provider| params[:providers].include?(provider.provider_name.downcase) }
    end

    # TODO - yield cache_result if provider.cachable?
    results = providers.map do |provider|
      if provider.cachable?
        configuration.provider_cache.fetch(provider.cache_key, expires_in: provider.get_cache_interval) do
          provider_result(provider, request)
        end
      else
        provider_result(provider, request)
      end
    end

    {
      results: results,
      status: results.any? { |res| res[:status] != STATUSES[:ok] } ? :service_unavailable : :ok,
      timestamp: Time.now.to_formatted_s(:rfc2822)
    }
  end

  private

  def provider_result(provider, request)
    monitor = provider.new(request: request)
    monitor.check!

    {
      name: provider.provider_name,
      message: '',
      status: STATUSES[:ok]
    }
  rescue StandardError => e
    configuration.error_callback.try(:call, e)

    {
      name: provider.provider_name,
      message: e.message,
      status: STATUSES[:error]
    }
  end
end

HealthMonitor.configure
