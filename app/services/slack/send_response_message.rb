module Slack
  class SendResponseMessage
    def initialize(response_url)
      @url = URI.parse(response_url)
      @conn = Faraday.new(url: @url.origin)
    end

    def call(text:, type: nil)
      body = if type == "in_channel"
        {text: text, response_type: type}
      else
        {text: text}
      end

      @conn.post(@url.path, body.to_json, {"Content-Type" => "application/json"})
    end
  end
end
