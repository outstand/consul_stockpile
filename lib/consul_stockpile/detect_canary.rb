require 'metaractor'

module ConsulStockpile
  class DetectCanary
    include Metaractor

    KEY = 'stockpile/canary'.freeze

    def call
      canary = Diplomat::Kv.get(KEY, {}, :return)
      context.exists = canary != ''
    end
  end
end
