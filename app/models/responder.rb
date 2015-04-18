class Responder < ActiveRecord::Base
  self.inheritance_column = 'inherits_from'

  validates :capacity, presence: true,
                       inclusion: { in: 1..5 }
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false }
  validates :type, presence: true

  def to_params
    name
  end
end
