class Responder < ActiveRecord::Base
  self.inheritance_column = 'inherits_from'

  RESPONDER_TYPES = %w(Fire Medical Police)

  validates :capacity, presence: true,
                       inclusion: { in: 1..5 }
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false }
  validates :type, presence: true

  scope :of_type,     -> (type)     { where(type: type) }
  scope :unassigned,  ->            { where(emergency_code: nil) }
  scope :on_duty,     ->            { where(on_duty: true) }
  scope :available,   ->            { on_duty.unassigned }
  scope :appropriate, -> (severity) { order("abs(capacity - #{severity}) asc") }
  scope :capable,     -> (severity) { where('capacity >= ?', severity) }

  # Class methods

  def self.allocate_responders(type, severity, code)
    responders = of_type(type).available
    if capacity_of(responders) < severity
      responders.find_each { |responder| responder.assign_code(code) }
      return false
    elsif responders.capable(severity).any?
      assign_responders(responders.capable(severity), severity, code)
    else
      assign_responders(responders, severity, code)
    end
  end

  def self.assign_responders(responders, severity, code)
    while severity > 0
      responder = responders.appropriate(severity).first
      responder.assign_code(code)
      severity -= responder.capacity
    end
    true
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
    RESPONDER_TYPES.each do |type|
      severity = emergency.send(type.downcase + '_severity')
      responses << allocate_responders(type, severity, emergency.code)
    end
    emergency.confirm_full_response if responses.all?
  end

  def self.emergency_capacities
    capacities = {}
    RESPONDER_TYPES.each do |type|
      capacities[type] = capacities_for(type)
    end
    capacities
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
