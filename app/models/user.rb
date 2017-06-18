class User < ActiveRecord::Base
  store_accessor :json_store, :profile_pic, :state

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
  STATE = {0 => "ask_for_role"}

  def on_postback(postback)
    payload = postback.payload
    case payload
    when "continue_customer"
      update_attributes(role: "customer", state: 1)
      postback.reply(text: I18n.t('signed_up_as_customer'))
    when "continue_business_owner"
      update_attributes(role: "business", state: 1)
      postback.reply(text: I18n.t('signed_up_as_business'))
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
      message.reply(text:"role in")
    end
  end

  def send_message(message)
    
  end

end
