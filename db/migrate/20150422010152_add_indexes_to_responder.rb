class AddIndexesToResponder < ActiveRecord::Migration
  def change
    add_index :responders, :emergency_code
    add_index :responders, :type
    add_index :responders, :capacity
  end
end
