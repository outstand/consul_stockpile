require 'consul_stockpile/base'

module ConsulStockpile
  class WatchEvent < Base
    def call
      puts 'watch'
    end
  end
end
