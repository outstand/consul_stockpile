require 'concurrent'
require 'concurrent-edge'
require 'consul_stockpile/bootstrap_consul_kv'

module ConsulStockpile
  class BootstrapConsulKVActor < Concurrent::Actor::RestartingContext
    def on_message(message)
      if message == :bootstrap
        begin
          BootstrapConsulKV.call
        rescue => e
          puts "Warning: #{e.message}; retrying in 5 seconds"
          Concurrent::ScheduledTask.execute(5){ tell :bootstrap }
        end
      else
        pass
      end
    end
  end
end
