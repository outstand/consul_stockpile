require 'metaractor'
require 'excon'

module ConsulStockpile
  class DetectConsul
    include Metaractor

    URL = 'http://127.0.0.1:8500/v1/agent/self'.freeze

    def call
      running = true
      begin
        Excon.get(
          URL,
          expects: [200],
          connect_timeout: 5,
          read_timeout: 5,
          write_timeout: 5,
          tcp_nodelay: true
        )
      rescue Excon::Errors::SocketError, Excon::Errors::HTTPStatusError
        running = false
      end

      context.running = running
    end
  end
end
