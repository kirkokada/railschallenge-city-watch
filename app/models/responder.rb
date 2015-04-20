class Responder < ActiveRecord::Base
  self.inheritance_column = 'inherits_from'

  validates :capacity, presence: true,
                       inclusion: { in: 1..5 }
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false }
  validates :type, presence: true

  scope :of_type,     -> (type) { where(type: type) }
  scope :unassigned,  -> { where(emergency_code: nil) }
  scope :on_duty,     -> { where(on_duty: true) }
  scope :available,   -> { on_duty.unassigned }
  scope :appropriate, -> (severity) { order("abs(capacity - #{severity}) asc") }

  # Class methods

  def self.allocate_responders(type, severity, code)
    all_responders = of_type(type).available
    if capacity_of(all_responders) < severity
      all_responders.find_each { |responder| responder.assign_code(code) }
      return false
    else
      while severity > 0
        responder = all_responders.appropriate(severity).first
        responder.assign_code(code)
        severity -= responder.capacity
      end
      return true
    end
  end

  def self.capacities_for(type)
    capacities = []
    responders = of_type(type)
    capacities << capacity_of(responders)
    capacities << capacity_of(responders.unassigned)
    capacities << capacity_of(responders.on_duty)
    capacities << capacity_of(responders.available)
  end

  def self.capacity_of(responders)
    responders.sum(:capacity)
  end

  def self.dispatch_to(emergency)
    responses = []
    responder_types.each do |type|
      severity = emergency.send(type.downcase + '_severity')
      responses << allocate_responders(type, severity, emergency.code)
    end
    emergency.confirm_full_response if responses.all?
  end

  def self.emergency_capacities
    capacities = {}
    responder_types.each do |type|
      capacities[type] = capacities_for(type)
    end
    capacities
  end

  def self.responder_types
    Responder.uniq.pluck(:type)
  end

  # Instance Methods

  def assign_code(code)
    update_attribute(:emergency_code, code)
  end

  def dismiss
    update_attribute(:emergency_code, nil)
  end

  def to_params
    name
  end
end
