module Slack
  class ClientWrapper
    def self.client
      return if disabled?

      @self ||= new
      @self.client
    end

    def self.reset!
      @self = nil
    end

    def self.disable!
      @disabled = true
    end

    def self.disabled?
      @disabled
    end

    def self.enable!
      @disabled = false
    end

    attr_reader :client
    def initialize
      @client = Slack::Web::Client.new
    end
  end
end
