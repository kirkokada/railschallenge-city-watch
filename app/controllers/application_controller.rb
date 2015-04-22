class ApplicationController < ActionController::Base
  rescue_from ActionController::RoutingError, with: :page_not_found
  rescue_from ActiveRecord::RecordNotFound,   with: :page_not_found

  rescue_from ActionController::UnpermittedParameters do |exception|
    render json: { message: exception.message }, status: :unprocessable_entity
  end

  private

  def page_not_found
    render json: { message: 'page not found' }, status: :not_found
  end

  def render_errors_for(resource)
    render json: { message: resource.errors }, status: :unprocessable_entity
  end
end
