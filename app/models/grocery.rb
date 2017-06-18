class Grocery < ApplicationRecord
  default_scope {order(name: :asc)}
  has_and_belongs_to_many :users, join_table: "user_grocery_mappings"

  def children
    Grocery.where(parent_id: self.id)
  end

  def parent
    Grocery.find(parent_id) rescue self
  end

  def self.top_categories
    Grocery.where(parent_id: nil)
  end
  COUNT = 7
  # MAX_PAGE_CATAGORIES = (Grocery.top_categories.count/10.0).ceil.to_i
  # MAX_PAGE_TOTAL = (Grocery.count/10.0).ceil.to_i

  def send_select_list(message, page)
    children.offset(COUNT*page).limit(COUNT).each do |item|
      
    end
  end

  def self.search(query)
    Grocery.where("name ilike ?", "%#{query}%")
  end

  def self.send_items(message)
    query = message.text
    items = Grocery.search(query)
    elements = []
    items.each do |item|
      elements << {
        title: item.name,
        subtitle: item.parent.name,
        buttons: [
          {
            title: I18n.t("select"),
            type: "postback",
            payload: "search_business:#{item.id}"
          }
        ]
      }
    end
    User.send_list(message, elements, [])
  end

#   items = ["1","2","3","4", "5"]
# elements = []
# items.each do |item|
#   elements << {
#     title: "title " + item,
#     subtitle: "sub " + item,
#     buttons: [
#       {
#       title: "buton title " + item,
#       type: "postback",
#       payload: "chus" + item
#       }
#     ]
#   }
# end
#  User.send_list(message, elements, [])
end
