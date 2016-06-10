require 'metaractor'
require 'consul_stockpile/consul_lock'
require 'consul_stockpile/detect_canary'
require 'consul_stockpile/download_backup'
require 'consul_stockpile/load_json_kv'
require 'consul_stockpile/logger'
require 'consul_stockpile/place_canary'
require 'consul_stockpile/bootstrap_external_services'

module ConsulStockpile
  class BootstrapConsulKV
    include Metaractor

    LOCK_KEY = 'stockpile/bootstrap'.freeze

    required :bucket

    def call
      Logger.tagged('Bootstrap') do
        Logger.info 'Starting Consul KV Bootstrap...'

        ConsulLock.with_lock(key: LOCK_KEY) do
          if DetectCanary.call!.exists
            Logger.info 'Canary detected; skipping bootstrap.'
            context.ran_bootstrap = false
            return
          end

          json = DownloadBackup.call!(bucket: bucket).json_body
          LoadJsonKV.call!(json: json)
          BootstrapExternalServices.call!
          PlaceCanary.call!
        end

        Logger.info 'Bootstrap complete.'
        context.ran_bootstrap = true
      end
    end

    private
    def bucket
      context.bucket
    end
  end
end
