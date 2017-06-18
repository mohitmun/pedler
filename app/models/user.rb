class User < ActiveRecord::Base
  store_accessor :json_store, :profile_pic, :state
  has_and_belongs_to_many :groceries, -> { uniq }, join_table: "user_grocery_mappings"
  def self.create_from_message(message)
    user = User.create(fb_id: message.sender['id'], state: 0)
    user.save_fb_profile
    user.send_welcome_message(message)
  end

  def get_fb_profile
    res = `curl https://graph.facebook.com/v2.6/#{fb_id}?access_token=#{ENV['ACCESS_TOKEN']}`
    json_res = JSON.parse(res)
    return json_res
  end

  def self.process_csv
    res = Hash.new([])
    grocery_csv = CSV.read("grocery.csv")
    processd_csv = grocery_csv.map{|a| a.map{|b| b.to_s.sub("· ", "")}}
    processd_csv = processd_csv.transpose
    processd_csv.each do |row|
      header = true
      row.each do |item|
        if item.blank?
          header = true
          next
        else
          if header
            res[item]
          end
        end
      end
    end
  end

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

  # [
  #       {
  #         "title": "Chus title",
  #         "subtitle": "Chus subtitle",
  #         "buttons": [
  #           {
  #             "title": "View",
  #             "type": "postback",
  #             "payload": "chussandas"
  #           }
  #         ]
  #       },{
  #         "title": "Chus title1",
  #         "subtitle": "Chus subtitle1",
          
  #         "buttons": [
  #           {
  #             "title": "View",
  #             "type": "postback",
  #             "payload": "chussandas"
  #           }
  #         ]
  #       }
  #     ]
  
  # buttons
  # [
  #       {
  #         "title": "View More",
  #         "type": "postback",
  #         "payload": "payload"
  #       }
  #     ]
  def self.send_list(message, elements, buttons)
    message.reply(
      "attachment": 
      {
        "type": "template",
        "payload": {
          "template_type": "list",
          "top_element_style": "compact",
          "elements": elements,
          "buttons": buttons
        }
    })
  end

  def save_fb_profile
    res = get_fb_profile
    self.first_name = res["first_name"]
    self.last_name = res["last_name"]
    self.profile_pic = res["profile_pic"]
    self.save
  end

  def send_buttons(message, text, buttons_hash)
    buttons = []
    buttons_hash.each do |k,v|
      buttons << {type: 'postback', title: v, payload: k}
    end
    message.reply(
      attachment: {
       type: 'template',
        payload: {
          template_type: 'button',
          text: text,
          buttons: buttons
        }
      }
    )
  end

  def send_welcome_message(message)
    # message.reply(text: I18n.t('hello', name: first_name))
    buttons = {"continue_business_owner" => I18n.t('continue_business_owner'),  "continue_customer" => I18n.t('continue_customer')}
    send_buttons(message, I18n.t('hello', name: first_name), buttons)
  end
  STATE = {0 => "ask_for_role", 1 => "ask_for_business", 2 => "ask_for_location"}

  def on_postback(postback)
    payload = postback.payload
    
    if payload == "continue_customer"
      update_attributes(role: "customer", state: 1)
      postback.reply(text: I18n.t('signed_up_as_customer'))
      return
    elsif payload == "continue_business_owner"
      update_attributes(role: "business", state: 1)
      postback.reply(text: I18n.t('signed_up_as_business'))
      return
    # end
    elsif payload.include?("list_categories")
      send_select_list_categories(postback, payload.split(":").last.to_i)
    end
  end

  def start_flow(message)
    if self.state.blank?
      self.state = 0
    else 
      self.state = state.to_i
    end
    case self.state
    when 0
      send_welcome_message(message)
    when 1
      ask_for_business(message)
    end
  end

  def ask_for_business(message)
    # Grocery.send_select_list(message, 1)
    message.reply(text: I18n.t("select_grocery"))
    send_select_list_categories(message, 1)
  end

  def send_select_list_categories(message, page)
    elements = []
    buttons = []
    if(Grocery.top_categories.count - Grocery::COUNT*page > 0)
      buttons << {
        "title": "View More(#{page*Grocery::COUNT}/#{Grocery.top_categories.count})",
        "type": "postback",
        "payload": "list_categories:#{page+1}"
      }
    end
    Grocery.top_categories.offset(Grocery::COUNT*page).limit(Grocery::COUNT).each do |item|
      element_buttons = [
          {
            "title": I18n.t('select'),
            "type": "postback",
            "payload": "select_grocery:#{item.id}"
          }
          # ,
          # {
          #   "title": I18n.t('remove'),
          #   "type": "postback",
          #   "payload": "remove_grocery:#{item.id}"
          # },
          # {
          #   "title": I18n.t('show_items'),
          #   "type": "postback",
          #   "payload": "show_items_grocery:#{item.id}"
          # }
        
        ]
      element = {
        "title": item.name,
        "subtitle": item.children.map(&:name).join(","),
        "buttons": element_buttons
      }
      elements << element
    end
    User.send_list(message, elements, buttons)
  end


  def self.chus
    
  end

end
