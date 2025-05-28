class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  before_action :authenticate_organization!
  before_action :set_organization_as_current_tenant
  helper_method :is_app?
  helper_method :is_mobile?
  # allow_browser versions: :modern
  before_action :is_mobile?


  def set_organization_as_current_tenant
    set_current_tenant current_organization
  end

  def is_app?
    request.user_agent == "react-native"
  end

  def is_mobile?
    browser = Browser.new(request.user_agent)
    browser.device.mobile?
  end
end
