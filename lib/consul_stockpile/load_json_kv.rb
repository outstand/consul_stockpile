require 'consul_stockpile/base'

module ConsulStockpile
  class LoadJsonKV < Base
    attr_accessor :json

    def initialize(json:)
      self.json = json
    end

    def call
      puts 'load json kv'
    end
  end
end
