class PagesController < ApplicationController
  skip_before_action :authenticate_organization!, except: [ :new_message ]
  skip_before_action :verify_authenticity_token, only: [ :sign_up_form ]

  def home
    @contacts = Contact.all.sort_by { |c| c.name.to_s }
  end

  def about
  end

  def sign_up
  end

  def sign_up_form
    flash[:notice] = "You have successfully opted in to recieving sms!"
    redirect_to "/sign_up"
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
