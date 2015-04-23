class Emergency < ActiveRecord::Base
  validates :code, presence: true,
                   uniqueness: { case_sensitive: false }
  validates :police_severity,  presence: true,
                               numericality: { greater_than_or_equal_to: 0 }
  validates :fire_severity,    presence: true,
                               numericality: { greater_than_or_equal_to: 0 }
  validates :medical_severity, presence: true,
                               numericality: { greater_than_or_equal_to: 0 }

  has_many :responders, foreign_key: :emergency_code, primary_key: :code

  after_update :dismiss_responders

  scope :full_responses, -> { where(full_response: true) }

  def responder_names
    responders.pluck(:name)
  end

  def confirm_full_response
    update_attribute(:full_response, true)
  end

  def to_param
    code
  end

  private

  def dismiss_responders
    return unless resolved_at && resolved_at < Time.zone.now
    responders.clear
  end
end
