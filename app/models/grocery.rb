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

  
  def self.grocery_json
    YAML.load(File.read("grocery.yml"))
  end

  def self.create_groceries
    a = User.grocery_json
    a.each do |top, child_array|
      g = Grocery.create(name: top)
      child_array.each do |item|
        Grocery.create(name: item, parent_id: g.id)
      end
    end
  end

  
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
            payload: "search_stores:#{item.id}"
          }
        ]
      }
    end
    User.send_list(message, elements, [])
  end


  def self.send_stores(postback, current_user)
    payload = postback.payload
    grocery_id = payload.split(":").last
    grocery = Grocery.find(grocery_id)
    grocery.send_stores(postback, current_user)
  end

  def send_stores(message, current_user)
    elements = []
    distance = 4 #TODO 
    users.each do |user|
      buttons = []
      buttons << {
        title: I18n.t("call"),
        type: "phone_number",
        payload: user.phone
      }
      buttons << {
        title: I18n.t("order_online"),
        type: "postback",
        payload: "order:#{user.id}"
      }  if user.delivery?
      elements << {
        title: user.display_name,
        subtitle: I18n.t("store_subtitle", distance: distance, address: "Mumbai"),
        buttons: buttons
      }
    end
    message.reply(
      "attachment": 
      {
        "type": "template",
        "payload": {
          "template_type": "generic",
          "elements": elements
        }
      })
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
