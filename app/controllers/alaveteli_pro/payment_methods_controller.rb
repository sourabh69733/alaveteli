# -*- encoding : utf-8 -*-
class AlaveteliPro::PaymentMethodsController < AlaveteliPro::BaseController
  before_filter :authenticate

  def update
    begin
      @token = Stripe::Token.retrieve(params[:stripeToken])
      @old_card_id = params[:old_card_id]
      @customer = Stripe::Customer.
                    retrieve(current_user.pro_account.stripe_customer_id)
      @customer.sources.create(source: @token.id)
      @customer.default_source = @token.card.id
      @customer.save
      flash[:notice] = _('Your payment details have been updated')
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to subscription_path
      return
    rescue Stripe::RateLimitError,
           Stripe::InvalidRequestError,
           Stripe::AuthenticationError,
           Stripe::APIConnectionError,
           Stripe::StripeError => e
      if send_exception_notifications?
        ExceptionNotifier.notify_exception(e, :env => request.env)
      end
      flash[:error] = _('There was a problem updating your payment details. ' \
                        'Please try again later.')
      redirect_to subscription_path
      return
    end
    begin
      @customer.sources.retrieve(@old_card_id).delete
    rescue Stripe::Error
      # should generate an error email here but probably doesn't need a user
      # message as the new card has been added and there's no further action
      if send_exception_notifications?
        ExceptionNotifier.notify_exception(e, :env => request.env)
      end
    end
    redirect_to subscription_path
  end

  private

  def authenticate
    post_redirect_params = {
      :web => _('To update your payment details'),
      :email => _('To update your payment details'),
      :email_subject => _('To update your payment details') }
    authenticated?(post_redirect_params)
  end

end
