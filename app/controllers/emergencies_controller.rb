class EmergenciesController < ApplicationController
  respond_to :json
  before_action :reject_unpermitted_parameters, only: [:create, :update]
  before_action :find_emergency, only: [:show, :update]

  def index
    @emergencies = Emergency.all
  end

  def show
  end

  def create
    @emergency = Emergency.new(emergency_params)
    if @emergency.save
      Responder.dispatch_to(@emergency)
      render 'show', status: :created
    else
      @messages = @emergency.errors
      render 'shared/messages', status: :unprocessable_entity
    end
  end

  def update
    if @emergency.update_attributes(emergency_params)
      render 'show'
    else
      @messages = @emergency.errors
      render 'shared/messages', status: :unprocessable_entity
    end
  end

  private

  def find_emergency
    @emergency = Emergency.find_by_code!(params[:id])
  end

  def emergency_params
    params.require(:emergency).permit(:code,
                                      :police_severity,
                                      :fire_severity,
                                      :medical_severity,
                                      :resolved_at)
  end

  def unpermitted_parameters
    if params[:action] == 'create'
      [:id, :resolved_at]
    elsif params[:action] == 'update'
      [:id, :code]
    else
      []
    end
  end
end
