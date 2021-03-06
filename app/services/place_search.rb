class PlaceSearch

  attr_accessor :category, :city, :partner, :name

  def initialize(category: nil, city: nil, partner: nil, name: nil, page: 1)
    @category = Category.find(category) if category.present?
    @city = city.presence
    @partner = partner
    @name = name
    @page = page
  end

  def places
    return @places if @places.present?

    base_scope = if category.present?
      category.places
    elsif partner.present?
      partner.live_places
    else
      Place
    end
    base_scope = base_scope.includes(:category).published

    @places = base_scope
    @places = @places.where(area: city) if city.present?
    @places = @places.where('name ILIKE ?', "%#{name}%") if name.present?

    @places = @places.sorted.page(@page)
  end

  def title
    if category.nil? && city.nil?
      "Todos os locais"
    else
      "#{category&.name_plural || 'Locais'} em #{city.presence || 'todo o país'}"
    end
  end
end
