class Grocery < ApplicationRecord
  default_scope {order(name: :asc)}
  scope :top_categories,  -> {where(parent_id: nil)}
  has_and_belongs_to_many :users, -> {where(role: "business")}, join_table: "user_grocery_mappings"

  def children
    Grocery.where(parent_id: self.id)
  end

  def parent
    Grocery.find(parent_id) rescue self
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
    if elements.blank?
      message.reply(text: I18n.t("no_items"))
    else
      User.send_list(message, elements, [])
    end
  end


  def self.send_stores(postback, current_user)
    payload = postback.payload
    grocery_id = payload.split(":").last
    grocery = Grocery.find(grocery_id)
    grocery.send_stores_for_item(grocery, postback,current_user)
  end

  def cost
    #lol
    #free world
    (self.id%10)*10
  end

  def self.send_store_items(message, items, order_id)
    elements = []
    items.each do |item|
      buttons = []
      buttons << {
        title: I18n.t("add_to_order"),
        type: "postback",
        payload: "add_to_order_item:#{item.id}:#{order_id}"
      }
      buttons << {
        title: I18n.t("view_order"),
        type: "postback",
        payload: "view_order:#{order_id}" 
      }
      buttons << {
        title: I18n.t("place_order"),
        type: "postback",
        payload: "place_order:#{order_id}" 
      }
      elements << {
        title: item.name,
        subtitle: "Rs #{item.cost}",
        buttons: buttons
      }
    end
    Grocery.send_generic(message, elements)
  end

  def self.send_store_categories(message, items, order_id)
    elements = []
    items.each do |item|
      buttons = []
      buttons << {
        title: I18n.t("select"),
        type: "postback",
        payload: "selected_category:#{item.id}:#{order_id}"
      }
      elements << {
        title: item.name,
        subtitle: item.children.pluck(:name).join(","),
        buttons: buttons
      }
    end
    Grocery.send_generic(message, elements)
  end

  def cal_distance(loc1, loc2)
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    rm * c # Delta in meters
  end


  def send_stores_for_item(grocery, message, current_user)
    elements = []
    
    parent.users.each do |user|
      buttons = []
      distance = cal_distance(current_user.latlong, user.latlong)/1000.0
      distance = distance.round(2)
      buttons << {
        title: I18n.t("call"),
        type: "phone_number",
        payload: user.phone
      }
      buttons << {
        title: I18n.t("order_online"),
        type: "postback",
        payload: "order_from_store_item:#{grocery.id}:#{user.id}"
      }  if user.delivery?
      elements << {
        title: user.display_name,
        subtitle: I18n.t("store_subtitle", distance: distance, address: "Mumbai"),
        buttons: buttons
      }
    end
    if elements.blank?
      message.reply(text: I18n.t("no_stores"))
    else
      message.reply(text: I18n.t("total_stores_found", count: elements.count))
      Grocery.send_generic(message, elements)
    end
  end

  def self.send_generic(message, elements)
    puts elements
    this_times = (elements.count/10.0).ceil
    this_times.times do |i|
      message.reply(
        "attachment": 
        {
          "type": "template",
          "payload": {
            "template_type": "generic",
            "elements": elements[i*10..(i*10)+9]
          }
        })
    end
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
