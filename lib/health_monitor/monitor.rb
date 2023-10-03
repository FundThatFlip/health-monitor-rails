# frozen_string_literal: true

require 'health_monitor/configuration'

module HealthMonitor
  STATUSES = {
    ok: 'OK',
    warning: 'WARNING',
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

    results = providers.map do |provider|
      if provider.cachable?
        if configuration.provider_results_cache.get(provider.cache_key)
           Rails.logger.info("Using cache for #{provider.cache_key}")
        else
          Rails.logger.info("Setting #{provider.cache_key}")
          # https://redis.io/commands/set/#options
          configuration.provider_results_cache.set(
            provider.cache_key, provider_result(provider, request).to_json,
            nx: true,
            ex: provider.cache_interval
          )
        end

        JSON.parse(
          configuration.provider_results_cache.get(
            provider.cache_key
          )
        ).transform_keys(&:to_sym)
      else
        provider_result(provider, request)
      end
    end

    {
      results: results,
      status: results.any? { |res| res[:status] == STATUSES[:error] } ? :service_unavailable : :ok,
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
      status: provider.critical ? STATUSES[:error] : STATUSES[:warning]
    }
  end
end

HealthMonitor.configure
