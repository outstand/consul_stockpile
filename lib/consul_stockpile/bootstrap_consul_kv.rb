require 'consul_stockpile/base'
require 'consul_stockpile/consul_lock'
require 'consul_stockpile/detect_canary'
require 'consul_stockpile/download_backup'
require 'consul_stockpile/load_json_kv'
require 'consul_stockpile/logger'
require 'consul_stockpile/place_canary'
require 'consul_stockpile/bootstrap_external_services'

module ConsulStockpile
  class BootstrapConsulKV < Base
    LOCK_KEY = 'stockpile/bootstrap'.freeze

    attr_accessor :bucket

    def initialize(bucket:)
      self.bucket = bucket
    end

    def call
      Logger.tagged('Bootstrap') do
        Logger.info 'Starting Consul KV Bootstrap...'

        ConsulLock.with_lock(key: LOCK_KEY) do
          if DetectCanary.call.exists
            Logger.info 'Canary detected; skipping bootstrap.'
            return OpenStruct.new(ran_bootstrap: false)
          end

          json = DownloadBackup.call(bucket: bucket).json_body
          LoadJsonKV.call(json: json)
          BootstrapExternalServices.call
          PlaceCanary.call
        end

        Logger.info 'Bootstrap complete.'
        OpenStruct.new(ran_bootstrap: true)
      end
    end
  end
end
