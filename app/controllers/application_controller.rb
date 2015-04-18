class ApplicationController < ActionController::Base
  rescue_from ActionController::RoutingError, with: :page_not_found
  rescue_from ActiveRecord::RecordNotFound,   with: :page_not_found

  private

  def page_not_found
    render json: { message: 'page not found' }, status: 404
  end

  def reject_unpermitted_parameters
    resource = controller_name.singularize.to_sym
    unpermitted_parameters.each do |parameter|
      if params[resource].key?(parameter)
        @messages = "found unpermitted parameter: #{parameter}"
        render 'shared/messages', status: :unprocessable_entity
      end
    end
  end

  # Define in resource controller

  def unpermitted_parameters
    fail 'Define me!'
  end

  def render_errors_for(resource)
    @messages = resource.errors
    render 'shared/messages', status: :unprocessable_entity
  end
end
