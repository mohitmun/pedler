class CreateUserGroceryMappings < ActiveRecord::Migration[5.1]
  def change
    create_table :user_grocery_mappings do |t|
      t.integer :grocery_id
      t.integer :user_id

      t.timestamps
    end
  end
end
