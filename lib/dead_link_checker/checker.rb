require "dead_link_checker/notifiers/slack_notifier"

class DeadLinkChecker::Checker
  # API endpoint returning links to check as a JSON array, e.g:
  # [
  #   "https://example.com/link-1",
  #   "https://example.com/link-2",
  #   "https://example.com/link-3",
  # ]
  JOBS_LIST_URL = ENV.fetch("LINK_LIST_URL").freeze
  PRIMARY_WAIT_TIME = ENV.fetch("PRIMARY_WAIT_TIME", 5).to_i
  ON_FAILL_WAIT_TIME = ENV.fetch("ON_FAILL_WAIT_TIME",  30).to_i
  RETRY_COUNT = ENV.fetch("RETRY_COUNT",  3).to_i

  def run!
    check_dead_links
  end

  private

  def check(link)
    puts "Checking #{link}"

    check_link_with_retries(RETRY_COUNT, link) do |i|
      http.follow.get(link)
    end
  end

  def check_dead_links
    links.each { |link| check(link) }
  end

  def links
    JSON.parse(http_json.get(JOBS_LIST_URL))
  end

  def http_json
    @_http_json ||= HTTP.headers("Content-Type" => "application/json")
  end

  def http
    @_http ||= HTTP
  end

  def check_link_with_retries(retry_count, link, &block)
    (1..retry_count).each do |i|
      begin
        sleep(PRIMARY_WAIT_TIME)

        resp = block.call

        if dead?(resp)
          fail "Failed to fetch #{link} (non-200 response)"
        else
          return
        end
      rescue => e
        puts "Failed checking #{link}\n#{e.message}"

        if i == retry_count
          notify_of_failure(link)
          return
        end

        sleep(ON_FAILL_WAIT_TIME)
      end
    end
  end

  def dead?(resp)
    return true if resp.code != 200

    false
  end

  def notify_of_failure(link)
    slack_notifier.notify(slack_payload(link))
  end

  def slack_payload(link)
    <<~END
      <!channel> *[Dead link]* Dead link found:
      #{link}
    END
  end

  def slack_notifier
    @_slack_notifier ||= SlackNotifier.new
  end
end
