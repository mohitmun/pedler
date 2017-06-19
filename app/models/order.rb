class Order < ApplicationRecord
  store_accessor :json_store, :item_ids, :store_id
  after_initialize :init
  belongs_to :user

  def init
    self.item_ids = [] if self.item_ids.blank?
  end

  def add_item(grocery_id)
    self.item_ids << grocery_id
    self.save
  end

  def cost
    res = 0
    item_ids.each do |item_id|
      res = res + Grocery.find(item_id).cost
    end
    return res
  end

  def place(message1)
    user.send_message(text: I18n.t("order_placed", cost: cost, order_id: self.id + 10000))
    store = User.find(store_id)
    result = I18n.t("order_received", from: user.first_name) + "\n"
    result = result + list_and_total
    # store.send_message(text: message)
    buttons = []
      buttons << {
        title: I18n.t("get_directions"),
        type: "web_url",
        url: "http://maps.google.com/maps?saddr=#{store.latlong.join(",")}&daddr=#{user.latlong.join(",")}"
      }
    message = {
      "attachment": 
        {
          "type": "template",
          "payload": {
            "template_type": "button",
            "text": result,
            "buttons": buttons
          }
      }
    }
    store.send_message(message) rescue nil
    # http://maps.google.com/maps?saddr=new+york&daddr=baltimore
  end

  def list_and_total
    result = ""
    item_ids.uniq.each do |item_id|
      item = Grocery.find(item_id)
      result = result + item.name + "(#{item_ids.count(item_id)}): Rs.#{item.cost}\n" 
    end
    result = result + "Total: Rs.#{cost}"
    return result
  end

  def self.view_order(message)
    order_id = message.payload.split(":").last
    order = Order.find order_id
    result = I18n.t("items_in_order") + "\n"
    item_ids = order.item_ids
    item_ids.uniq.each do |item_id|
      item = Grocery.find(item_id)
      result = result + item.name + "(#{item_ids.count(item_id)}): Rs.#{item.cost}\n" 
    end
    result = result + "Total: Rs.#{order.cost}"
    message.reply(text: result, quick_replies: [
        {
          title: I18n.t("place_order"),
          content_type: "text",
          payload: "place_order:#{order.id}"
        }
      ])

  end

end
