class CreateGroceries < ActiveRecord::Migration[5.1]
  def change
    create_table :groceries do |t|
      t.text :name
      t.integer :parent_id

      t.timestamps
    end
  end
end
