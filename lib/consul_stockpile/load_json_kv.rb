require 'metaractor'
require 'consul_stockpile/logger'

module ConsulStockpile
  class LoadJsonKV
    include Metaractor

    optional :json

    def call
      Logger.info 'Loading json backup into consul kv store'

      return if json.nil?
      ary = JSON.parse(json)
      return if ary.empty?

      ary.each do |item|
        Diplomat::Kv.put(item['key'], item['value'])
      end
    end

    private
    def json
      context.json
    end
  end
end
