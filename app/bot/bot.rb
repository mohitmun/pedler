include Facebook::Messenger
puts "w"
Bot.on :message do |message|
  message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
  message.sender      # => { 'id' => '1008372609250235' }
  message.seq         # => 73
  message.sent_at     # => 2016-04-22 21:30:36 +0200
  message.text        # => 'Hello, bot!'
  message.attachments # => [ { 'type' => 'image', 'payload' => { 'url' => 'https://www.example.com/1.jpg' } } ]
  puts "Woah"
  # message.reply(text: 'Hello, human!')
  user = User.find_by(fb_id: message.sender['id']) rescue nil
  Rails.cache.write("chus", message)
  if user.blank?
    User.create_from_message(message)
  else
    user.start_flow(message)
  end
end

Bot.on :postback do |postback|
  postback.sender    # => { 'id' => '1008372609250235' }
  postback.recipient # => { 'id' => '2015573629214912' }
  postback.sent_at   # => 2016-04-22 21:30:36 +0200
  postback.payload   # => 'EXTERMINATE'

  user = User.find_by(fb_id: postback.sender['id']) rescue nil
  if user.blank?
    User.create_from_message(postback)
  else
    user.on_postback(postback)
  end
  
end

Facebook::Messenger::Profile.set({
  get_started: {
    payload: 'GET_STARTED_PAYLOAD'
  }
}, access_token: ENV['ACCESS_TOKEN'])
Facebook::Messenger::Profile.set({
  persistent_menu: [
    {
      locale: 'default',
      composer_input_disabled: true,
      call_to_actions: [
        {
        title: "My Account",
        type: 'nested',
        call_to_actions: [ 
          {
            title: 'My Wallet',
            type: 'nested',
            call_to_actions: [
              {
                title: 'View Balance',
                type: 'postback',
                payload: 'view_balance'
              },
              {
                title: 'Add money',
                type: 'postback',
                payload: 'add_money'
              },
              {
                title: 'Show transactions',
                type: 'postback',
                payload: 'show_transactions'
              }
            ]
          },
          {
            type: 'postback',
            title: 'Update Location',
            payload: 'update_location'
          },
          {
            type: 'postback',
            title: 'Change Role',
            payload: 'change_role'
          }
        ]},
        {
          type: 'postback',
          title: 'More Settings',
          payload: 'more_settings'
        }
      ]
    }
  ]
}, access_token: ENV['ACCESS_TOKEN'])