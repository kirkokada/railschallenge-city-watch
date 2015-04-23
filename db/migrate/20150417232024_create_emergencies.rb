class CreateEmergencies < ActiveRecord::Migration
  def change
    create_table :emergencies do |t|
      t.string :code,              null: false
      t.integer :fire_severity,    default: 0
      t.integer :police_severity,  default: 0
      t.integer :medical_severity, default: 0
      t.boolean :full_response,    default: false
      t.time :resolved_at

      t.timestamps null: false
    end

    add_index :emergencies, :code, unique: true
  end
end
