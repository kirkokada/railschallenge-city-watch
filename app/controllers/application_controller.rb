class ApplicationController < ActionController::Base
  rescue_from ActionController::RoutingError, with: :page_not_found
  rescue_from ActiveRecord::RecordNotFound,   with: :page_not_found

  private
    def page_not_found
      render json: { message: 'page not found' }, status: 404
    end

    def reject_unpermitted_parameters
      resource = controller_name.singularize.to_sym
      unpermitted_parameters.each do |parameter|
        if params[resource].has_key?(parameter)
          @messages = "found unpermitted parameter: #{parameter.to_s}"
          render 'shared/messages', status: :unprocessable_entity
        end
      end
    end

    # Define in resource controller
    
    def unpermitted_parameters
      raise "Define me!" 
    end
end