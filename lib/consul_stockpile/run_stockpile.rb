require 'consul_stockpile/base'
require 'concurrent'
require 'consul_stockpile/detect_consul'
require 'consul_stockpile/bootstrap_consul_kv_actor'
require 'consul_stockpile/watch_event_actor'
require 'consul_stockpile/backup_consul_kv_actor'

module ConsulStockpile
  class RunStockpile < Base
    attr_accessor :bucket, :name, :verbose

    def initialize(bucket:, name:, verbose: false)
      self.bucket = bucket
      self.name = name
      self.verbose = verbose
    end

    def call
      Concurrent.use_stdlib_logger(Logger::DEBUG) if self.verbose

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
        while !DetectConsul.call.running
          puts 'Local consul agent not detected, sleeping for 5 seconds'
          sleep 5
        end

        backup_actor = BackupConsulKVActor.spawn(
          :backup_consul_kv,
          bucket: self.bucket,
          name: self.name
        )

        BootstrapConsulKVActor.spawn(:bootstrap_consul_kv, backup_actor: backup_actor)
        WatchEventActor.spawn(:watch_event, backup_actor: backup_actor)


        while readable_io = IO.select([self_read])
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end

      rescue Interrupt
        puts 'Exiting'
        # actors are cleaned up in at_exit handler
        exit 0
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
  end
end
