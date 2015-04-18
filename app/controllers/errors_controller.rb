class ErrorsController < ApplicationController
  def catch_404
    fail ActionController::RoutingError.new(params[:path]), 'page not found'
  end
end
