module Chatops
  class SlackSlashCommand < Struct.new(:channel_name, :user_id, :text, keyword_init: true)
  end
end
