# frozen_string_literal: true
class PaymentService

  ENDPOINT = ENV['PAYMENT_ENDPOINT']
  RESPONSES = {
    0 => 'Sucesso',
    -7 => 'Serviço Inativo',
    -8 => 'Referência Inválida',
    -9 => 'Valores Incorretos',
    -10 => 'Chave Inválida'
  }.freeze

  attr_accessor :api_key,
                :method,
                :payment_phone,
                :value,
                :identifier,
                :seller_name

  def initialize(voucher)
    @api_key = voucher.place.seller.payment_api_key
    @method = voucher.payment_method
    @payment_phone = voucher.payment_phone
    @value = voucher.value
    @identifier = voucher.payment_identifier
    @seller_name = voucher.place.name
  end

  def request_payment
    case method
    when 'MB'
      process_mb
    when 'MBW'
      process_mbw
    end
  end

  private

  def process_mb
    url = ENDPOINT + '/multibanco/create'

    params = build_mb_params
    result = RestClient.post url, params
    result = JSON.parse result.body

    if result['sucesso'] && result['estado'].zero?
      build_mb_response(result)
    else
      get_error(result)
    end
  end

  def process_mbw
    url = ENDPOINT + '/mbway/create'
    params = build_mbw_params

    result = RestClient.post url, params
    result = JSON.parse result.body

    if result['sucesso'] && result['estado'].zero?
      build_mbw_response(result)
    else
      get_error(result)
    end
  end

  def get_error(response)
    state = RESPONSES[response['estado']]
    message = response['resposta']
    Rails.logger.warn("Payment API Error for transaction '#{identifier}''. State: '#{response['estado']}'' - '#{state}''. Message: '#{message}''")
    OpenStruct.new(success: false, state: state, message: message)
  end

  def build_mb_params
    {
      chave: api_key,
      valor: value.to_f,
      id: identifier,
      data_inicio: Date.today.to_s,
      data_fim: 2.days.from_now.to_date.to_s,
      per_dup: '1'
    }
  end

  def build_mb_response(result)
    OpenStruct.new(
      success: true,
      entity: result['entidade'],
      ref: result['referencia'],
      value: result['valor']
    )
  end

  def build_mbw_params
    {
      chave: api_key,
      valor: value.to_f,
      id: identifier,
      alias: payment_phone,
      descricao: "Voucher para #{seller_name}"
    }
  end

  def build_mbw_response(result)
    OpenStruct.new(
      success: true,
      ref: result['referencia'],
      value: result['valor'],
      phone: result['alias'].split('#').last
    )
  end

end
