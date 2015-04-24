# == Schema Information
#
# Table name: responders
#
#  id             :integer          not null, primary key
#  type           :string           not null
#  name           :string           not null
#  capacity       :integer          not null
#  on_duty        :boolean          default(FALSE)
#  emergency_code :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Responder < ActiveRecord::Base
  self.inheritance_column = :_type

  RESPONDER_TYPES = %w(Fire Medical Police)

  validates :capacity, presence: true,
                       inclusion: { in: 1..5 }
  validates :name,     presence: true,
                       uniqueness: { case_sensitive: false }
  validates :type,     presence: true

  scope :of_type,     -> (type)     { where(type: type) }
  scope :unassigned,  ->            { where(emergency_code: nil) }
  scope :on_duty,     ->            { where(on_duty: true) }
  scope :available,   ->            { on_duty.unassigned }
  scope :appropriate, -> (severity) { order("abs(capacity - #{severity}) asc") }
  scope :capable_of,  -> (severity) { where('capacity >= ?', severity) }

  #
  # Wrapper method to update a responder's emergency_code
  #
  # code: string
  #
  def assign_code(code)
    update_attribute(:emergency_code, code)
  end

  #
  # Assigns the code to a responder and returns true if a single responder
  # of the given type that can handle an emergency of the given severity exists.
  # Returns the result of assign_responders for the given type, severity, and code
  # otherwise.
  #
  # type: string
  # severity: integer
  # code: string
  #
  def self.allocate_responders(type, severity, code)
    best_responder = most_appropriate_for(type, severity)
    if best_responder
      best_responder.assign_code(code)
      return true
    else
      assign_responders(type, severity, code)
    end
  end

  #
  # Returns an array of the capacity of:
  # - All responders of the type
  # - Responders of the type that have not been assigned an emergency code
  # - Responders of the type that are on duty
  # - Responders of the type that have not been assigned an emergency code and
  #   are on duty
  #
  # type: string
  #
  def self.capacities_for(type)
    capacities = []
    responders = of_type(type)
    capacities << capacity_of(responders)
    capacities << capacity_of(responders.unassigned)
    capacities << capacity_of(responders.on_duty)
    capacities << capacity_of(responders.available)
  end

  #
  # Iterates through the three severities of the given emergency,
  # allocates responders for each severity, and collects the
  # responses from the allocate_responders method.
  # Sets the emergency's full_response attribute to true if all calls to
  # allocate_responders return true.
  #
  # emergency: Emergency instance
  #
  def self.dispatch_to(emergency)
    responses = []
    RESPONDER_TYPES.each do |type|
      severity = emergency.send("#{type.downcase}_severity")
      responses << allocate_responders(type, severity, emergency.code)
    end
    emergency.confirm_full_response if responses.all?
  end

  #
  # Returns a hash with the responder types as keys and arrays for their various
  # capacities as values.
  #
  def self.emergency_capacities
    capacities = {}
    RESPONDER_TYPES.each do |type|
      capacities[type] = capacities_for(type)
    end
    capacities
  end

  #
  # Iterates through the available responders in order
  # of appropriateness of their capacity with respect to the given severity
  # and assigns them the given error code until the total of capacity of assigned
  # responders is equal to or greater than the severity or no available responders
  # are left. Returns true if assigned responder capacity is exceeded,
  # false otherwise.
  #
  # type: string
  # severity: integer
  # code: string
  #
  def self.assign_responders(type, severity, code)
    while severity > 0
      responders = of_type(type).available.appropriate(severity)
      return false unless responders.any?
      responder = responders.first
      responder.assign_code(code)
      severity -= responder.capacity
    end

    true
  end

  #
  # Returns the responder of the given type whose capacity is equal to or greater
  # than the given severity and whose capacity least differs from the severity.
  #
  def self.most_appropriate_for(type, severity)
    return nil if severity == 0
    of_type(type).available.capable_of(severity).appropriate(severity).first
  end

  #
  # Returns an integer representing the capacity of a group of responders.
  #
  # responders: ActiveRecord::Relation
  #
  def self.capacity_of(responders)
    responders.sum(:capacity)
  end
end
