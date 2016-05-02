require 'consul_stockpile/base'

module ConsulStockpile
  class LoadJsonKV < Base
    def call
      puts 'load json kv'
    end
  end
end
