class RespondersController < ApplicationController
  before_action :reject_unpermitted_parameters, only: [:create, :update]

  def index
    if params[:show] == 'capacity'
      @capacities = Responder.emergency_capacities
      render 'capacities'
    else
      @responders = Responder.all
    end
  end

  def show
    @responder = Responder.find_by!(name: params[:id])
  end

  def create
    @responder = Responder.new(responder_params)
    if @responder.save
      render 'show', status: :created
    else
      render_errors_for @responder
    end
  end

  def update
    @responder = Responder.find_by!(name: params[:id])
    if @responder.update_attributes(responder_params)
      render 'show', status: :ok
    else
      render_errors_for @responder
    end
  end

  private

  def responder_params
    params.require(:responder).permit(:name,
                                      :type,
                                      :capacity,
                                      :on_duty)
  end

  def unpermitted_parameters
    if params[:action] == 'create'
      [:id, :emergency_code, :on_duty]
    elsif params[:action] == 'update'
      [:id, :capacity, :emergency_code, :type, :name]
    else
      []
    end
  end
end
