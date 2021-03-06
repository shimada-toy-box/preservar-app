# frozen_string_literal: true
class Partner < ApplicationRecord

  include PartnerLogoUploader::Attachment.new(:large_logo)
  include PartnerLogoUploader::Attachment.new(:small_logo)

  has_many :partnerships, inverse_of: :partner, dependent: :destroy
  has_many :places, through: :partnerships, inverse_of: :partner
  has_many :live_partnerships, -> { where(approved: true, limit_reached: false)}, class_name:'Partnership'
  has_many :live_places, through: :live_partnerships, class_name:'Place', source: :place

  has_many :vouchers
  has_many :partner_identifiers

  def logo_url
    large_logo_url(public: true)
  end

  def thumb_logo_url
    small_logo_url(public: true)
  end

  def add_on_partner?
    false
  end

  def charity_partner?
    false
  end

  def marketing_partner?
    false
  end

  def active?
    true
  end

  def restricted_category_id
    partner_properties['restricted_category_id']
  end

  def min_value
    partner_properties['min_value'].to_i
  end

  def min_value=(value)
    partner_properties['min_value'] = value
  end

  def target_value
    partner_properties['target_value']&.to_i
  end

  def target_value=(value)
    partner_properties['target_value'] = value
  end

  def restricted_category_ids
    partner_properties['restricted_category_ids']
  end

  def restricted_category_ids=(value)
    partner_properties['restricted_category_ids'] = value.delete_if(&:blank?)
  end

  def restricted_categories
    if partner_properties['restricted_category_ids'].present?
      Category.where(id: partner_properties['restricted_category_ids'])
    end
  end

  def restricted_categories=(categories)
    partner_properties['restricted_category_ids'] = categories.map(&:id)
  end

  def requires_partner_id_code
    partner_properties['requires_partner_id_code'] || false
  end

  def requires_partner_id_code=(value)
    partner_properties['requires_partner_id_code'] = value == '1'
  end

  def requires_honor_check
    partner_properties['requires_honor_check'] || false
  end

  def requires_honor_check=(value)
    partner_properties['requires_honor_check'] = value == '1'
  end

  def to_s
    "#{self.class}: #{name}"
  end

  def self.inherited(subclass)
    super

    def subclass.model_name
      super.tap do |name|
        route_key = base_class.name.underscore
        name.instance_variable_set(:@singular_route_key, route_key)
        name.instance_variable_set(:@route_key, route_key.pluralize)
      end
    end
  end
end
