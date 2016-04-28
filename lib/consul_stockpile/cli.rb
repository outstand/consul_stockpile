require 'thor'

module ConsulStockpile
  class CLI < Thor
    desc 'version', 'Print out the version string'
    def version
      require 'consul_stockpile/version'
      say ConsulStockpile::VERSION.to_s
    end

    desc 'start', 'Start the stockpile'
    def start
      $stdout.sync = true
      require 'consul_stockpile/run_stockpile'
      RunStockpile.call(
      )
    end
  end
end
