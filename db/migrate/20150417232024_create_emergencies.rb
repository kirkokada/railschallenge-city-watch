class CreateEmergencies < ActiveRecord::Migration
  def change
    create_table :emergencies do |t|
      t.string :code,              null: false
      t.integer :fire_severity,    null: false
      t.integer :police_severity,  null: false
      t.integer :medical_severity, null: false
      t.boolean :full_response,    default: false
      t.time :resolved_at

      t.timestamps null: false
    end

    add_index :emergencies, :code, unique: true
  end
end
