# frozen_string_literal: true
class ShrineDeleteJob < ApplicationJob
  queue_as :default

  def perform(attacher_class, data)
    attacher_class = Object.const_get(attacher_class)

    attacher = attacher_class.from_data(data)
    attacher.destroy
  end
end