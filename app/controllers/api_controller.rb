class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_organization!
  def textgrid_webhook
    organization = Organization.find_by(textgrid_phone_number: params["To"])
    ActsAsTenant.with_tenant(organization) do
      contact = Contact.find_by(phone: params["From"])
      message = params["Body"]
      unsubscribe_keywords = [ "opt out", "optout", "stop", "unsubscribe", "exit", "cancel", "#exit", "#stop" ]
      if message.to_s.downcase.strip.in?(unsubscribe_keywords)
        if contact
          contact.update(opted_in_status: 2)
          head :ok and return
        else
          head :ok and return
        end
      end
      message_body = "#{contact&.name || params["From"] } said: #{message}"
      send_sms(contact, message_body, organization)
      MessageReceived.create!(
        body: message,
        from: params["From"],
        organization_id: organization.id
      )
    end
    head :ok
  end

  def send_sms(contact, what, organization)
    url = URI("#{ENV.fetch("BASE_TEXTGRID_URL")}/Accounts/#{organization.textgrid_account_sid}/Messages.json")
    response = HTTParty.post(
      url,
      body: {
        "to" => organization.admin_phone_number,
        "from" => organization.textgrid_phone_number,
        "body" => what
      }.to_json,
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{organization.encoded_textgrid_credentials}"
      },
    )
    if response.code != 200
      Rails.logger.error("Failed to send SMS: #{response.code} - #{response.message}")
    else
      Rails.logger.info("SMS sent successfully to #{contact.name}: #{what}")
    end
    admin = Contact.find_by(phone: organization.admin_phone_number)
    MessageSent.create!(
      body: what,
      contact_id: admin&.id
    )
  end
end
