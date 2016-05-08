require 'consul_stockpile/base'

module ConsulStockpile
  class PlaceCanary < Base
    KEY = 'stockpile/canary'.freeze

    def call
      Diplomat::Kv.put(KEY, 'tweet'.freeze)
    end
  end
end
