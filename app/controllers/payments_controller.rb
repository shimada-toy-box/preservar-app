# frozen_string_literal: true
class PaymentsController < ApplicationController
  before_action :load_and_check_voucher
  before_action :ensure_voucher_state, only: %i[new create]

  def new
  end

  def create
    @voucher.assign_attributes(payment_params)

    if @voucher.start_payment!
      @payment_request = PaymentService.new(@voucher).request_payment
      if @payment_request.success
        @partial = "payment_data_#{@voucher.payment_method.downcase}"
      else
        @voucher.reset_payment!
      end
    else
      render :new
    end
  end

  def done
    @other_places = OtherPlacesQuery.for_place(@voucher.place)
  end

  private

  def payment_params
    params.require(:voucher).permit(:email, :payment_method, :payment_phone, :vat_id)
  end

  def load_and_check_voucher
    redirect_to(root_url) and return unless Flipper.enabled?(:selling)

    @voucher = Voucher.find(params[:voucher_id] || params[:id])

    unless cookies.encrypted[:uuid] == @voucher.cookie_uuid
      redirect_to(@voucher.place, alert: 'Operação inválida') and return
    end
  end

  def ensure_voucher_state
    unless @voucher.created?
      redirect_to(@voucher.place, alert: 'Operação inválida') and return
    end
  end
end
