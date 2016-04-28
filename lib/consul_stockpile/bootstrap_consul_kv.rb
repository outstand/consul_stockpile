require 'consul_stockpile/base'

module ConsulStockpile
  class BootstrapConsulKV < Base
    def call
      puts 'bootstrap'
    end
  end
end
