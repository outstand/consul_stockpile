require 'metaractor'
require 'excon'
require 'diplomat'
require 'consul_stockpile/logger'

module ConsulStockpile
  class BootstrapExternalServices
    include Metaractor

    KEY_PREFIX = 'stockpile/external_services'.freeze
    URL = 'http://127.0.0.1:8500/v1/catalog/register'.freeze

    def call
      Logger.tagged('Bootstrap') do
        Logger.info 'Loading external services into catalog...'

        services = Diplomat::Kv.get(KEY_PREFIX, {recurse: true}, :return)
        services = [] if services == ''
        services = [{key: :unknown, value: services}] if services.is_a? String

        services.each do |service|
          Excon.put(
            URL,
            body: service[:value],
            headers: {
              'Content-Type' => 'application/json',
            },
            expects: [200],
            connect_timeout: 5,
            read_timeout: 5,
            write_timeout: 5,
            tcp_nodelay: true
          )
        end

        Logger.info 'Done loading external services.'
      end
    end
  end
end
