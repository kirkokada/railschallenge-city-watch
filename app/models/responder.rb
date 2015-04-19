class Responder < ActiveRecord::Base
  self.inheritance_column = 'inherits_from'

  RESPONDER_TYPES = ['Fire', 'Medical', 'Police']

  validates :capacity, presence: true,
                       inclusion: { in: 1..5 }
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false }
  validates :type, presence: true

  scope :of_type, -> (type) { where type: type }
  scope :available, -> { where emergency_code: nil }
  scope :on_duty, -> { where on_duty: true }

  def self.emergency_capacities
    capacities = Hash.new
    RESPONDER_TYPES.each do |t|
      responders = Responder.of_type(t)
      capacities[t] = []
      capacities[t] << capacity_of(responders)
      capacities[t] << capacity_of(responders.available)
      capacities[t] << capacity_of(responders.on_duty)
      capacities[t] << capacity_of(responders.available.on_duty)
    end
    return capacities
  end

  def self.capacity_of(responders)
    n = responders.map(&:capacity).reduce(:+)
    n.nil? ? 0 : n
  end

  def to_params
    name
  end
end
