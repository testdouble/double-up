module Mailer
  class GroupingMailerParameters < Struct.new(:channel, :grouping, :other_members, keyword_init: true)
  end
end
