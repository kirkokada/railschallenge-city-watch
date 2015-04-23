class EmergenciesController < ApplicationController
  respond_to :json

  def index
    @emergencies = Emergency.all
    @full_responses = [Emergency.where(full_response: true).count,
                       Emergency.count]
  end

  def show
    find_emergency
  end

  def create
    @emergency = Emergency.new(emergency_create_params)
    if @emergency.save
      Responder.dispatch_to(@emergency)
      render :show, status: :created
    else
      render_errors_for @emergency
    end
  end

  def update
    find_emergency
    if @emergency.update_attributes(emergency_update_params)
      @emergency.dismiss_responders
      render :show
    else
      render_errors_for @emergency
    end
  end

  private

  def find_emergency
    @emergency = Emergency.find_by_code!(params[:id])
  end

  def emergency_create_params
    params.require(:emergency).permit(:code,
                                      :police_severity,
                                      :fire_severity,
                                      :medical_severity)
  end

  def emergency_update_params
    params.require(:emergency).permit(:police_severity,
                                      :fire_severity,
                                      :medical_severity,
                                      :resolved_at)
  end
end
