class PagesController < ApplicationController
  skip_before_action :authenticate_organization!, only: [ :privacy_policy, :terms_of_service, :about, :contact ]

  def home
    @contacts = Contact.all.sort_by { |c| c.name.to_s }
  end

  def about
  end

  def contact
  end

  def privacy_policy
  end

  def terms_of_service
  end

  def new_message
    @contacts = Contact.all.sort_by { |c| c.name.to_s }
  end
end
