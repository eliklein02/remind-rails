class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  before_action :authenticate_organization!
  before_action :set_organization_as_current_tenant
  helper_method :is_app?
  # allow_browser versions: :modern


  def set_organization_as_current_tenant
    set_current_tenant current_organization
  end

  def is_app?
    request.user_agent == "react-native"
  end
end
