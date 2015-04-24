# == Schema Information
#
# Table name: emergencies
#
#  id               :integer          not null, primary key
#  code             :string           not null
#  fire_severity    :integer          not null
#  police_severity  :integer          not null
#  medical_severity :integer          not null
#  resolved_at      :time
#  full_response    :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Emergency < ActiveRecord::Base
  validates :code, presence: true,
                   uniqueness: { case_sensitive: false }
  validates :police_severity, :fire_severity, :medical_severity,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  has_many :responders, foreign_key: :emergency_code, primary_key: :code

  #
  # Wrapper method to set full_respons to true.
  #
  def confirm_full_response
    update_attribute(:full_response, true)
  end

  #
  # Returns an array of responders assigned to the emergency instance.
  #
  def responder_names
    responders.pluck(:name)
  end

  #
  # Removes all responder relations if the emergency is resolved
  #
  def dismiss_responders
    responders.clear if resolved_at && resolved_at < Time.zone.now
  end
end
