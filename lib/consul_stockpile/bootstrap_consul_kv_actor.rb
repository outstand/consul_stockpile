require 'concurrent'
require 'concurrent-edge'
require 'consul_stockpile/bootstrap_consul_kv'
require 'consul_stockpile/logger'

module ConsulStockpile
  class BootstrapConsulKVActor < Concurrent::Actor::RestartingContext
    def initialize(backup_actor:, bucket:)
      @backup_actor = backup_actor
      @bucket = bucket
      tell :bootstrap
    end

    def on_message(message)
      if message == :bootstrap
        Logger.tagged('Bootstrap') do
          begin
            ran_bootstrap = BootstrapConsulKV.call(bucket: @bucket).ran_bootstrap
            @backup_actor << :backup if ran_bootstrap
          rescue => e
            Logger.warn "Warning: #{e.message}; retrying in 5 seconds"
            Concurrent::ScheduledTask.execute(5){ tell :bootstrap }
          end
        end
      else
        pass
      end
    end
  end
end
