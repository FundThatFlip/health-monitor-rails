# frozen_string_literal: true

module HealthMonitor
  class HealthController < ActionController::Base
    protect_from_forgery with: :exception

    if Rails.version.starts_with? '3'
      before_filter :authenticate_with_basic_auth
    else
      before_action :authenticate_with_basic_auth
    end

    def check
      @statuses = statuses
      @hide_footer = HealthMonitor.configuration.hide_footer

      respond_to do |format|
        format.html
        format.json { render json: statuses.to_json, status: statuses[:status] }
        format.xml { render xml: statuses.to_xml, status: statuses[:status] }
      end
    end

    def print
      puts JSON.pretty_generate(self.request.env.reject {|k,v| /action_dispatch\..*/ =~ k})
    end

    private

    def statuses
      res = HealthMonitor.check(request: request, params: providers_params)
      res.merge(env_vars)
    end

    def env_vars
      v = HealthMonitor.configuration.environment_variables || {}
      v.empty? ? {} : { environment_variables: v }
    end

    def authenticate_with_basic_auth
      return true unless HealthMonitor.configuration.basic_auth_credentials

      credentials = HealthMonitor.configuration.basic_auth_credentials
      authenticate_or_request_with_http_basic do |name, password|
        name == credentials[:username] && password == credentials[:password]
      end
    end

    def providers_params
      params.except(:format).permit(providers: [])
    end
  end
end
