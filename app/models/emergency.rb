class Emergency < ActiveRecord::Base
  def to_param
    code
  end
end
