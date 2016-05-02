require 'thor'

module ConsulStockpile
  class CLI < Thor
    desc 'version', 'Print out the version string'
    def version
      require 'consul_stockpile/version'
      say ConsulStockpile::VERSION.to_s
    end

    desc 'start', 'Start the stockpile'
    option :bucket, aliases: '-b', required: true, type: :string, banner: '<s3_bucket>'
    option :name, aliases: '-n', required: true, type: :string
    option :verbose, aliases: '-v', type: :boolean, default: false
    def start
      $stdout.sync = true
      require 'consul_stockpile/run_stockpile'
      RunStockpile.call(
        bucket: options[:bucket],
        name: options[:name],
        verbose: options[:verbose]
      )
    end
  end
end
