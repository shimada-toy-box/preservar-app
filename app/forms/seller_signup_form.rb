# frozen_string_literal: true
class SellerSignupForm
  include ActiveModel::Model
  include ActiveModel::AttributeMethods

  attr_accessor :name,
                :district,
                :area,
                :address,
                :category_id,
                :average_value_per_person,
                :main_photo,
                :email,
                :is_company,
                :vat_id,
                :iban,
                :contact_name,
                :company_name,
                :company_registration_code,
                :password,
                :password_confirmation

  attr_writer :seller, :seller_user

  validates :name,
            :address,
            :contact_name,
            :password,
            :password_confirmation,
            :category_id,
            :main_photo,
            :company_name,
            :iban, presence: true

  validates :email, format: { with: Devise.email_regexp }

  validates :vat_id, valvat: true
  validates :company_registration_code,
            format: { with: /\d{4}-\d{4}-\d{4}/, allow_nil: true }

  validates :average_value_per_person, numericality: { min: 1, allow_nil: true }

  validate :validate_iban

  def initialize(attributes = {})
    super(attributes.reject{ |_, v| v.blank? })
    @name ||= seller_user&.seller&.name
    @area ||= seller_user&.seller&.area
    @address ||= seller_user&.seller&.address
    @email ||= seller_user.email
    @category_id ||= seller_user&.seller&.category_id
    @average_value_per_person ||= seller_user&.seller&.average_value_per_person
    @password ||= seller_user.password
    @password_confirmation ||= seller_user.password_confirmation
    @iban ||= seller_user&.seller&.iban
    @contact_name ||= seller_user&.seller&.contact_name
    @company_name ||= seller_user&.seller&.company_name
    @company_registration_code ||= seller_user&.seller&.company_registration_code

    @vat_id ||= seller_user&.seller&.vat_id
    if @vat_id&.match?(/\A\d{9}/)
      @vat_id = 'PT' + @vat_id
    end
  end

  def category
    @category ||= Category.find_by(id: category_id)
  end

  def seller_user
    @seller_user ||= SellerUser.new(email: email,
                                    password: password,
                                    password_confirmation: password_confirmation,
                                    seller: seller)
  end

  def seller
    @seller ||= Seller.new(name: name,
                           area: area,
                           address: address,
                           category_id: category_id,
                           average_value_per_person: average_value_per_person,
                           vat_id: vat_id,
                           iban: iban,
                           contact_name: contact_name,
                           company_name: company_name,
                           company_registration_code: company_registration_code,
                           main_photo: main_photo
                          )
  end

  def save
    return false unless valid?

    seller.save!
    seller_user.save!
  rescue StandardError => e
    copy_errors
    binding.pry
    false
  end

  private

  def copy_errors
    seller_user.errors.each do |attribute, error|
      errors.add(attribute, error)
    end
    seller.errors.each do |attribute, error|
      errors.add(attribute, error)
    end
  end

  def validate_iban
    errors.add(:iban, 'é inválido') unless Ibandit::IBAN.new(iban).valid?
  end

end