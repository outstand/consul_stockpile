require 'metaractor'
require 'excon'
require 'json'
require 'diplomat'
require 'consul_stockpile/consul_lock'
require 'consul_stockpile/logger'

module ConsulStockpile
  class WatchEvent
    include Metaractor

    EVENT = 'kv_update'.freeze
    URL = 'http://127.0.0.1:8500/v1/event/list'.freeze
    KEY = 'event/kv_update'.freeze
    LOCK_KEY = 'event/kv_update/lock'.freeze

    required :handler

    def call
      Logger.tagged('WatchEvent') do
        Logger.info "Watching for event: #{EVENT}"

        response = Excon.get(
          URL,
          query: {name: EVENT},
          expects: [200],
          connect_timeout: 5,
          read_timeout: 5,
          write_timeout: 5,
          tcp_nodelay: true
        )

        handle_events(response.body)

        loop do
          index = response.headers['X-Consul-Index']
          response = Excon.get(
            URL,
            query: {name: EVENT, index: index},
            expects: [200],
            connect_timeout: 5,
            read_timeout: 86400,
            write_timeout: 5,
            tcp_nodelay: true
          )

          handle_events(response.body)
        end
      end
    end

    private
    def handler
      context.handler
    end

    def handle_events(events)
      events = JSON.parse(events)
      return if events.empty?

      sift(events) do |event|
        handler.call(event)
      end
    end

    def sift(events)
      ConsulLock.with_lock(key: LOCK_KEY) do
        last_worked = Diplomat::Kv.get(KEY, {}, :return)
        # Work around diplomat returning "" instead of nil
        last_worked = nil if last_worked.empty?
        last_worked = last_worked.to_i unless last_worked.nil?

        event = events.last
        Logger.info "Sifting event: #{event.inspect}"
        ltime = event['LTime']
        if last_worked.nil? || ltime > last_worked
          yield event

          Diplomat::Kv.put(KEY, ltime.to_s)
        else
          Logger.info 'Skipping duplicate event'
        end
      end
    end
  end
end
