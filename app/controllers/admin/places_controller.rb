# frozen_string_literal: true
module Admin
  class PlacesController < Admin::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    # def update
    #   super
    #   send_foo_updated_email(requested_resource)
    # end

    def publish
      if requested_resource.can_publish?

        if requested_resource.published_at.nil?
          ApplicationMailer.seller_place_published_notification(requested_resource.id).deliver_later
        end
        requested_resource.update(published: true, published_at: Time.now)
      else
        flash[:alert] = "Can't publish. Place needs photo and payment API key"
      end
      redirect_to [:admin, requested_resource]
    end

    def unpublish
      requested_resource.update(published: false)
      redirect_to [:admin, requested_resource]
    end

    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    def find_resource(param)
      Place.friendly.find(param)
    end

    # The result of this lookup will be available as `requested_resource`

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    #
    # def scoped_resource
    #   resource_class.unscoped
    # end

    # Override `resource_params` if you want to transform the submitted
    # data before it's persisted. For example, the following would turn all
    # empty values into nil values. It uses other APIs such as `resource_class`
    # and `dashboard`:
    #
    def resource_params
      params.require(resource_class.model_name.param_key)
            .permit(dashboard.permitted_attributes << :partner_id)
            .transform_values { |v| read_param_value(v) }
    end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
