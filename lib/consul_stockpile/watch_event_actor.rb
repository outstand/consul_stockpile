require 'concurrent'
require 'concurrent-edge'
require 'consul_stockpile/watch_event'

module ConsulStockpile
  class WatchEventActor < Concurrent::Actor::RestartingContext
    def on_message(message)
      if message == :watch
        begin
          WatchEvent.call
        rescue => e
          puts "Warning: #{e.message}; retrying in 5 seconds"
          Concurrent::ScheduledTask.execute(5){ tell :watch }
        end
      else
        pass
      end
    end
  end
end
