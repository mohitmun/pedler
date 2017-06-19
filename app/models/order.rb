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

end
