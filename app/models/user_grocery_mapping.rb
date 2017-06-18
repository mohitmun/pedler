class UserGroceryMapping < ApplicationRecord
  validates_uniqueness_of :user_id, :scope => :grocery_id
end
