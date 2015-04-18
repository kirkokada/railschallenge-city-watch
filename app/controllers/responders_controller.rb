class RespondersController < ApplicationController

  def show
    @responder = Responder.find_by!(name: params[:id])
  end

  def destroy
    @responder = Responder.find_by!(name: params[:id])
  end
end
