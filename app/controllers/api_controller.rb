class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :textgrid_webhook ]
  def textgrid_webhook
    contacts = Contact.where(phone: params["From"])
    message = params["Body"]
    case message
    when "opt out", "optout", "stop", "unsubscribe", "exit", "cancel", "#exit", "#stop"
      if contact
        contacts.each do |c|
          c.update(opted_in_status: 2)
        end
      else
        nil
      end
    end
  end
end
