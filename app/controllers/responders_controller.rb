class RespondersController < ApplicationController
  before_action :reject_unpermitted_parameters, only: [:create, :update]

  def show
    @responder = Responder.find_by!(name: params[:id])
  end

  def create
    @responder = Responder.new(responder_params)
    if @responder.save
      render 'show', status: :ok
    else
      @messages = @responder.errors
      render 'shared/messages', status: :unprocessable_entity
    end
  end

  def destroy
    @responder = Responder.find_by!(name: params[:id])
  end

  private

    def responder_params
      params.require(:responder).permit(:name, 
                                        :type, 
                                        :emergency_code,
                                        :capacity,
                                        :on_duty)
    end

    def unpermitted_parameters
      if params[:action] == 'create'
        [:id, :emergency_code, :on_duty]
      elsif params[:action] == 'update'
        [:id]
      else
        []
      end
    end
end
