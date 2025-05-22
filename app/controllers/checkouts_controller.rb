class CheckoutsController < ApplicationController
  def show
    current_organization.set_payment_processor :stripe
    current_organization.payment_processor.customer_name

    @checkout_session = current_organization
      .payment_processor
      .checkout(
        mode: "payment",
        line_items: "price_1RQCooB3aaIIY4ri1h7h0TKE",
        success_url: checkout_success_url
      )

      redirect_to @checkout_session.url, allow_other_host: true
  end

  def success
    @session = Stripe::Checkout::Session.retrieve(params[:stripe_checkout_session_id])
    @line_items = @session.list_line_items
    @description = @line_items["data"][0]["description"]
    @price = @line_items["data"][0]["amount_total"].to_f / 100
  end
end
