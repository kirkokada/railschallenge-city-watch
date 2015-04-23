class RespondersController < ApplicationController
  def index
    if params[:show] == 'capacity'
      @capacity = Responder.emergency_capacities
      render json: { capacity: @capacity }
    else
      @responders = Responder.all
    end
  end

  def show
    find_responder
  end

  def create
    @responder = Responder.new(responder_create_params)
    if @responder.save
      render :show, status: :created
    else
      render_errors_for @responder
    end
  end

  def update
    find_responder
    if @responder.update_attributes(responder_update_params)
      render :show
    else
      render_errors_for @responder
    end
  end

  private

  def find_responder
    @responder = Responder.find_by_name!(params[:id])
  end

  def responder_create_params
    params.require(:responder).permit(:name,
                                      :type,
                                      :capacity)
  end

  def responder_update_params
    params.require(:responder).permit(:on_duty)
  end
end
