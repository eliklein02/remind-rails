class PagesController < ApplicationController
  skip_before_action :authenticate_organization!, except: [ :new_message, :account ]
  skip_before_action :verify_authenticity_token, only: [ :sign_up_form ]

  def home
    @contacts = Contact.all.sort_by { |c| c.name.to_s }
  end

  def about
  end

  def sign_up
  end

  def sign_up_form
    flash[:notice] = "You have successfully been added as a contact!"
    redirect_to "/sign_up"
  end

  def contact_us
    @params = params
  end

  def privacy_policy
  end

  def terms_of_service
  end

  def pricing
  end

  def account
    @messages = MessageSent.all
    @total_spent = @messages.count * 0.0035
    @messages_this_month = MessageSent.this_month
    @price_so_far = @messages_this_month.count * 0.0035
  end

  def new_message
    @contacts = Contact.all.sort_by { |c| c.name.to_s }
  end
end
