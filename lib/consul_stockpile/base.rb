require 'ostruct'

module ConsulStockpile
  class Base
    def self.call(*args)
      new(*args).call
    end

    def call
      OpenStruct.new()
    end
  end
end
