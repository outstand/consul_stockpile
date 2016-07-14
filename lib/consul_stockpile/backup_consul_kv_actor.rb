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
        Logger.tagged('Backup') do
          begin
            BackupConsulKV.call!(bucket: @bucket, name: @name)
          rescue => e
            Logger.warn "Warning: #{e.message}; retrying in 5 seconds"
            Logger.warn e.backtrace
            Concurrent::ScheduledTask.execute(5){ tell :backup }
          end
        end
        nil
      else
        pass
      end
    end
  end
end
