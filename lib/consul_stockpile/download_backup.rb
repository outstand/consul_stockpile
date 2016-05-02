require 'consul_stockpile/base'

module ConsulStockpile
  class DownloadBackup < Base
    def call
      puts 'download backup'

      OpenStruct.new(
        json_body: ''
      )
    end
  end
end
