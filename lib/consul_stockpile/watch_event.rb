require 'consul_stockpile/base'
require 'excon'
require 'json'
require 'diplomat'
require 'consul_stockpile/consul_lock'

module ConsulStockpile
  class WatchEvent < Base
    EVENT = 'kv_update'.freeze
    URL = 'http://127.0.0.1:8500/v1/event/list'.freeze
    KEY = 'event/kv_update'.freeze
    LOCK_KEY = 'event/kv_update/lock'.freeze

    attr_accessor :handler

    def initialize(handler:)
      self.handler = handler
    end

    def call
      puts "Watching for event: #{EVENT}"

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

    private
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
        last_worked = last_worked.to_i unless last_worked.empty?

        event = events.last
        puts "Sifting event: #{event.inspect}"
        ltime = event['LTime']
        if last_worked.nil? || ltime > last_worked
          yield event

          Diplomat::Kv.put(KEY, ltime.to_s)
        else
          puts 'Skipping duplicate event'
        end
      end
    end
  end
end
