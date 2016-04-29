require 'consul_stockpile/base'

module ConsulStockpile
  class BackupConsulKV < Base
    def call
      puts 'backup'
    end
  end
end
