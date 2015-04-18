class Emergency < ActiveRecord::Base
  validates :code, presence: true,
                   uniqueness: { case_sensitive: false }
  validates :police_severity,  presence: true,
                               numericality: { greater_than_or_equal_to: 0 }
  validates :fire_severity,    presence: true,
                               numericality: { greater_than_or_equal_to: 0 }
  validates :medical_severity, presence: true,
                               numericality: { greater_than_or_equal_to: 0 }

  def to_param
    code
  end
end
