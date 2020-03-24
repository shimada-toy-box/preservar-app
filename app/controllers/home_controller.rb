# frozen_string_literal: true
class HomeController < ApplicationController
  before_action :set_location

  def index
    @spinner_categories = Category.limit(5)
    @category = Category.find(1)
    render :index
  end

  def tos
  end

  def privacy
  end

  private

  def set_location
    location = request.location
    @city = location&.city.presence || location&.state.presence || 'Lisboa'
  end
end
