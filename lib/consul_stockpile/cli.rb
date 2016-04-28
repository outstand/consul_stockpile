require 'thor'

module ConsulStockpile
  class CLI < Thor
    desc 'version', 'Print out the version string'
    def version
      require 'consul_stockpile/version'
      say ConsulStockpile::VERSION.to_s
    end
  end
end
