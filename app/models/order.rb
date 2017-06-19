class Order < ApplicationRecord
  store_accessor :json_store, :item_ids, :store_id
  after_initialize :init

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

  def place(message)
    message.reply(text: I18n.t("order_placed", cost: cost, order_id: self.id + 10000))
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
