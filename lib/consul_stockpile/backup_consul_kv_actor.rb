require 'concurrent'
require 'concurrent-edge'
require 'consul_stockpile/backup_consul_kv'

module ConsulStockpile
  class BackupConsulKVActor < Concurrent::Actor::RestartingContext
    def initialize(bucket:, name:)
      @bucket = bucket
      @name = name
    end

    def on_message(message)
      if message == :backup
        begin
          BackupConsulKV.call(bucket: @bucket, name: @name)
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
