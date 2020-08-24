require "json"
require "slack-notifier"

module DeadLinkChecker
  module Notifiers
    class SlackNotifier
      def notify(payload)
        client.ping(payload)
      rescue => err
        puts "FAILED: #{err}"
      end

      private

      def client
        @_client ||= Slack::Notifier.new(ENV["SLACK_WEBHOOK"])
      end
    end
  end
end
