class CreateResponders < ActiveRecord::Migration
  def change
    create_table :responders do |t|
      t.string :type,           null: false
      t.string :name,           null: false
      t.integer :capacity,      null: false
      t.boolean :on_duty,       default: :false
      t.string :emergency_code, default: nil

      t.timestamps null: false
    end
    add_index :responders, :name,          unique: true
    add_index :responders, :emergency_code
    add_index :responders, :type
    add_index :responders, :capacity
  end
end
