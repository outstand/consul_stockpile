require 'metaractor'
require 'consul_stockpile/logger'
require 'concurrent'
require 'consul_stockpile/detect_consul'
require 'consul_stockpile/bootstrap_consul_kv_actor'
require 'consul_stockpile/watch_event_actor'
require 'consul_stockpile/backup_consul_kv_actor'

module ConsulStockpile
  class RunStockpile
    include Metaractor

    required :bucket, :name, :verbose

    before do
      context.verbose ||= false
    end

    def call
      Concurrent.use_stdlib_logger(Logger::DEBUG) if verbose

      self_read, self_write = IO.pipe
      %w(INT TERM).each do |sig|
        begin
          trap sig do
            self_write.puts(sig)
          end
        rescue ArgumentError
          puts "Signal #{sig} not supported"
        end
      end

      begin
        while !DetectConsul.call!.running
          Logger.warn 'Local consul agent not detected, sleeping for 5 seconds'
          sleep 5
        end

        backup_actor = BackupConsulKVActor.spawn(
          :backup_consul_kv,
          bucket: bucket,
          name: name
        )

        BootstrapConsulKVActor.spawn(
          :bootstrap_consul_kv,
          backup_actor: backup_actor,
          bucket: bucket
        )
        WatchEventActor.spawn(:watch_event, backup_actor: backup_actor)

        while readable_io = IO.select([self_read])
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end

      rescue Interrupt
        Logger.info 'Exiting'
      end
    end

    def handle_signal(sig)
      case sig
      when 'INT'
        raise Interrupt
      when 'TERM'
        raise Interrupt
      end
    end

    private
    def bucket
      context.bucket
    end

    def name
      context.name
    end

    def verbose
      context.verbose
    end
  end
end
