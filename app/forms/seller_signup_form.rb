# frozen_string_literal: true
class SellerSignupForm
  include ActiveModel::Model
  include ActiveModel::AttributeMethods

  attr_accessor :name,
                :district,
                :area,
                :address,
                :category_id,
                :main_photo,
                :cached_main_photo_data,
                :email,
                :is_company,
                :vat_id,
                :contact_name,
                :company_name,
                :password,
                :password_confirmation

  attr_writer :seller, :seller_user

  validates :name,
            :address,
            :district,
            :area,
            :contact_name,
            :password,
            :password_confirmation,
            :category_id,
            :main_photo,
            :company_name, presence: true

  validates :email, format: { with: Devise.email_regexp }

  validates :password, presence: true,
                       confirmation: true,
                       length: { within: Devise.password_length }

  validates :vat_id, valvat: true

  def initialize(attributes = {})
    super(attributes.reject { |_, v| v.blank? })
    @vat_id = 'PT' + @vat_id if @vat_id&.match?(/\A\d{9}\z/)

    @cached_main_photo_data = seller.cached_main_photo_data
  end

  def category
    @category ||= Category.find_by(id: category_id)
  end

  def seller_user
    @seller_user ||= SellerUser.new(email: email,
                                    password: password,
                                    password_confirmation: password_confirmation)
  end

  def seller
    @seller ||= Seller.new(name: name,
                           area: area,
                           address: address,
                           category_id: category_id,
                           vat_id: vat_id,
                           contact_name: contact_name,
                           company_name: company_name,
                           main_photo: main_photo,
                           seller_user: seller_user)
  end

  def save
    return false unless valid?

    seller_user.save!
    seller.save!
  rescue StandardError
    copy_errors
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

end
