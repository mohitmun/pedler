class Grocery < ApplicationRecord
  default_scope {order(name: :asc)}
  has_and_belongs_to_many :users, join_table: "user_grocery_mappings"

  def children
    Grocery.where(parent_id: self.id)
  end

  def parent
    Grocery.find(parent_i) rescue nil
  end

  def self.top_categories
    Grocery.where(parent_id: nil)
  end
  COUNT = 4
  # MAX_PAGE_CATAGORIES = (Grocery.top_categories.count/10.0).ceil.to_i
  # MAX_PAGE_TOTAL = (Grocery.count/10.0).ceil.to_i

  def send_select_list(message, page)
    children.offset(COUNT*page).limit(COUNT).each do |item|
      
    end
  end
end
