class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :first_name
      t.text :last_name
      t.json :json_store
      t.text :fb_id
      t.text :contact
      t.text :role

      t.timestamps null: false
    end
  end
end
