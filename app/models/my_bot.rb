# include Facebook::Messenger
# class MyBot
#   def self.init
#     puts "init called"
#     Bot.on :message do |message|
#       message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
#       message.sender      # => { 'id' => '1008372609250235' }
#       message.seq         # => 73
#       message.sent_at     # => 2016-04-22 21:30:36 +0200
#       message.text        # => 'Hello, bot!'
#       message.attachments # => [ { 'type' => 'image', 'payload' => { 'url' => 'https://www.example.com/1.jpg' } } ]
#       puts "Woah"
#       # message.reply(text: 'Hello, human!')
#       user = User.find_by(fb_id: message.sender['id']) rescue nil
#       if user.blank?
#         send_welcome_message(message)
#         message.reply(text: "User blank")
#       else
#         message.reply(text: "User presentop")
#       end
#     end

#     def self.send_welcome_message(message)
#       user = User.create(fb_id: message.sender['id'])
#       message.reply(I18n.t('hello'))
#     end
#   end
# end
# MyBot.init
# # payload = {
# #           recipient: {id: "1446977495324816"},
# #           message: {text: "chus"}
# #         }
# # Facebook::Messenger::Bot.deliver(payload, access_token: access_token)
