$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
::Dir.glob(::File.expand_path('../support/**/*.rb', __FILE__)).each { |f| require_relative f }

require 'fivemat'

RSpec.configure do |c|
  c.color = true
  c.order = :random
  c.formatter = 'Fivemat'
end
