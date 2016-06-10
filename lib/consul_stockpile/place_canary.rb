require 'metaractor'

module ConsulStockpile
  class PlaceCanary
    include Metaractor

    KEY = 'stockpile/canary'.freeze

    def call
      Diplomat::Kv.put(KEY, 'tweet'.freeze)
    end
  end
end
