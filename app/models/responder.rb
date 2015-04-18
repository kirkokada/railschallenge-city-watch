class Responder < ActiveRecord::Base

  def to_params
    name
  end
end
