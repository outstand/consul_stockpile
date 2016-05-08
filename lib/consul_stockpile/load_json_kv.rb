require 'consul_stockpile/base'
require 'consul_stockpile/logger'

module ConsulStockpile
  class LoadJsonKV < Base
    attr_accessor :json

    def initialize(json:)
      self.json = json
    end

    def call
      Logger.info 'Loading json backup into consul kv store'

      return if json.nil?
      ary = JSON.parse(json)
      return if ary.empty?

      ary.each do |item|
        Diplomat::Kv.put(item['key'], item['value'])
      end
    end
  end
end
