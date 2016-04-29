require 'concurrent'
require 'concurrent-edge'
require 'consul_stockpile/watch_event'

module ConsulStockpile
  class WatchEventActor < Concurrent::Actor::RestartingContext
    def initialize
      tell :watch
    end

    def on_message(message)
      if message == :watch
        begin
          WatchEvent.call(handler: ->(event){puts event['LTime'].inspect})
        rescue => e
          puts "Warning: #{e.message}; retrying in 5 seconds"
          puts e.backtrace
          Concurrent::ScheduledTask.execute(5){ tell :watch }
        end
      else
        pass
      end
    end
  end
end
