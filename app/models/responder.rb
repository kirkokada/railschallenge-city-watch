class Responder < ActiveRecord::Base
  self.inheritance_column = 'inherits_from'

  validates :capacity, presence: true,
                       inclusion: { in: 1..5 }
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false }
  validates :type, presence: true

  scope :of_type, -> (type) { where type: type }
  scope :available, -> { where emergency_code: nil }
  scope :on_duty, -> { where on_duty: true }

  def self.emergency_capacities
    capacities = {}
    Responder.uniq.pluck(:type).each do |t|
      capacities[t] = capacities_for(t)
    end
    capacities
  end

  def self.capacities_for(type)
    capacities = []
    responders = Responder.of_type(type)
    capacities << capacity_of(responders)
    capacities << capacity_of(responders.available)
    capacities << capacity_of(responders.on_duty)
    capacities << capacity_of(responders.available.on_duty)
  end

  def self.capacity_of(responders)
    n = responders.map(&:capacity).reduce(:+)
    n.nil? ? 0 : n
  end

  def to_params
    name
  end
end
