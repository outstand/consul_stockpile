require 'consul_stockpile/base'
require 'consul_stockpile/consul_lock'
require 'consul_stockpile/detect_canary'
require 'consul_stockpile/download_backup'
require 'consul_stockpile/load_json_kv'

module ConsulStockpile
  class BootstrapConsulKV < Base
    LOCK_KEY = 'stockpile/bootstrap'.freeze

    def call
      puts 'Starting Consul KV Bootstrap...'

      ConsulLock.with_lock(key: LOCK_KEY) do
        return if DetectCanary.call.exists

        json = DownloadBackup.call.json_body
        LoadJsonKV.call(json: json)
      end

      puts 'Bootstrap complete.'
    end
  end
end
