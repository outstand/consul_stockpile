require 'consul_stockpile/base'

module ConsulStockpile
  class DetectCanary < Base
    KEY = 'stockpile/canary'.freeze

    def call
      canary = Diplomat::Kv.get(KEY, {}, :return)
      OpenStruct.new(
        exists: canary != ""
      )
    end
  end
end
