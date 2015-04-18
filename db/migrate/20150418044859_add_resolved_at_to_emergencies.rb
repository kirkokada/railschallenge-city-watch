class AddResolvedAtToEmergencies < ActiveRecord::Migration
  def change
    add_column :emergencies, :resolved_at, :time
  end
end
