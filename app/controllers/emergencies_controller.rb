class EmergenciesController < ApplicationController
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :page_not_found

  def show
    @emergency = Emergency.find(code: params[:id])
    respond_with @emergency
  end

  def destroy
    emergency = Emergency.find(code: params[:id])

    emergency.destroy if emergency
  end
end
