require 'concurrent'
require 'concurrent-edge'
require 'consul_stockpile/backup_consul_kv'

module ConsulStockpile
  class BackupConsulKVActor < Concurrent::Actor::RestartingContext
    def on_message(message)
      if message == :backup
        begin
          BackupConsulKV.call
        rescue => e
          puts "Warning: #{e.message}; retrying in 5 seconds"
          puts e.backtrace
          Concurrent::ScheduledTask.execute(5){ tell :backup }
        end
      else
        pass
      end
    end
  end
end
