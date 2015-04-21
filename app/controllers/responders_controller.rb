class RespondersController < ApplicationController
  before_action :reject_unpermitted_parameters, only: [:create, :update]
  before_action :find_responder, only: [:show, :update]

  def index
    if params[:show] == 'capacity'
      @capacities = Responder.emergency_capacities
      render 'capacities'
    else
      @responders = Responder.all
    end
  end

  def show
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
    if @responder.update_attributes(responder_params)
      render 'show'
    else
      render_errors_for @responder
    end
  end

  private

  def find_responder
    @responder = Responder.find_by_name!(params[:id])
  end

  def responder_params
    params.require(:responder).permit(:name,
                                      :type,
                                      :capacity,
                                      :on_duty)
  end

  def unpermitted_create_params
    @unpermitted_create_params ||= [:id, :emergency_code, :on_duty]
  end

  def unpermitted_update_params
    @unpermitted_update_params ||= [:id,
                                    :capacity,
                                    :name,
                                    :type,
                                    :emergency_code]
  end
end
