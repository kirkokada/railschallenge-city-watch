class ApplicationController < ActionController::Base
  rescue_from ActionController::RoutingError, with: :page_not_found

  private
    def page_not_found
      render json: { message: 'page not found'}, status: 404
    end
end