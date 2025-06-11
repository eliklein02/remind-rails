class PagesController < ApplicationController
  skip_before_action :authenticate_organization!, except: [ :new_message, :account ]
  skip_before_action :verify_authenticity_token, only: [ :sign_up_form ]

  def home
    @contacts = Contact.all.sort_by { |c| c.name.to_s }
  end

  def about
  end

  def responses
    @responses = MessageReceived.all
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

  def sent
    @jobs = current_organization.job_results.sort_by { |j| j.created_at }.reverse
  end

  def job
    @job = JobResult.find_by(job_id: params[:job_id])
    puts @job.inspect
  end

  def privacy_policy
  end

  def terms_of_service
  end

  def pricing
  end

  def admin
    if params[:source].present? && params[:source] == "admin"
      @organizations = Organization.all.sort_by { |c| c.name.to_s }
      @contacts = Contact.all.sort_by { |c| c.name.to_s }
      @messages = MessageSent.all
      @total_spent = @messages.count * 0.0035
      @messages_this_month = MessageSent.this_month
      @price_so_far = @messages_this_month.count * 0.0035
    else
      redirect_to root_path
    end
  end

  def new_organization
    redirect_to root_path unless params[:source].present? && params[:source] == "admin"
    @organization = Organization.new
  end

  def new_organization_accept
    password = SecureRandom.hex(4)
    creds = convert_to_base_64(params[:organization][:textgrid_account_sid], params[:organization][:textgrid_auth_token])
    @organization = Organization.new(organization_params)
    @organization.country = "USA"
    @organization.encoded_textgrid_credentials = creds
    @organization.textgrid_phone_number = to_e164(params[:organization][:textgrid_phone_number])
    @organization.password = password
    puts password
    puts @organization.inspect
    if @organization.save
      flash[:notice] = "You have successfully created a new organization!"
      redirect_to "/new_organization?source=admin"
    else
      puts @organization.errors.full_messages
      flash[:error] = "There was an error creating the new organization."
      redirect_to "/new_organization?source=admin"
    end
  end


  def account
    @messages = MessageSent.all
    @total_spent = @messages.count * 0.0035
    @messages_this_month = MessageSent.this_month
    @price_so_far = @messages_this_month.count * 0.0035
    # @billing_portal = current_organization.payment_processor.billing_portal
  end

  def new_message
    @contacts = Contact.all.sort_by { |c| c.name.to_s }
  end

  def convert_to_base_64(account_sid, auth_token)
    creds = Base64.strict_encode64("#{account_sid}:#{auth_token}")
    creds
  end

  def to_e164(pn)
    phone = pn
    phone.gsub!(/[^0-9]/, "")
    phone = "+1#{phone[0..2]}#{phone[3..5]}#{phone[6..9]}" if phone.length === 10
    phone = "+1#{phone[1..3]}#{phone[4..6]}#{phone[7..10]}" if phone.length === 11
    phone
  end

  private


  def my_is_signed_up?
    current_organization.is_signed_up? if current_organization
  end

  def organization_params
    params.require(:organization).permit(
      :name,
      :email,
      :admin_phone_number,
      :textgrid_account_sid,
      :textgrid_auth_token,
      :textgrid_phone_number,
      :organization_type,
      :city
    )
  end
end
