require "shellwords"

module Slack
  class ParsesSlashArgsString
    SlashArgsParseResult = Struct.new(:subcommand, :args, keyword_init: true)

    def call(text:)
      words = Shellwords.shellwords(text)
      subcommand = words.shift&.downcase unless words.first&.match?(/=/)
      args = words.map { |word|
        word.split("=", 2)
          .tap { |w| w << "" }
          .slice(0, 2)
      }.to_h
        .transform_keys { |k|
          k.sub(/^-*/, "")
            .underscore
        }
      SlashArgsParseResult.new(
        subcommand: subcommand,
        args: args
      )
    end
  end
end
