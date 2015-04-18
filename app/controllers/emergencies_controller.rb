class EmergenciesController < ApplicationController
  respond_to :json
  before_action :reject_unpermitted_parameters, only: :create

  rescue_from ActiveRecord::RecordNotFound, with: :page_not_found

  def show
    @emergency = Emergency.find_by!(code: params[:id])
  end

  def create
    @emergency = Emergency.new(emergency_params)
    if @emergency.save
      render 'show', status: :ok
    else
      @messages = @emergency.errors
      render 'messages', status: :unprocessable_entity
    end
  end

  def destroy
    emergency = Emergency.find(code: params[:id])

    emergency.destroy if emergency
  end

  private

    def emergency_params
      params.require(:emergency).permit(:code, 
                                        :police_severity, 
                                        :fire_severity, 
                                        :medical_severity)
    end

    def reject_unpermitted_parameters
      unpermitted_parameters.each do |parameter|
        if params[:emergency].has_key?(parameter)
          @messages = "found unpermitted parameter: #{parameter.to_s}"
          render 'messages', status: :unprocessable_entity
        end
      end
    end

    def unpermitted_parameters
      [:id, :resolved_at]
    end
end
