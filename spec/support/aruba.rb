require 'aruba/rspec'
require 'consul_stockpile/cli'

class ThorMain
  def initialize(argv, stdin, stdout, stderr, kernel)
    @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
  end

  def execute!
    $stdin  = @stdin
    $stdout = @stdout
    $stderr = @stderr
    orig_program_name = $PROGRAM_NAME
    $PROGRAM_NAME = 'consul_stockpile'

    ConsulStockpile::CLI.start(@argv)
    @kernel.exit(0)
  ensure
    $stderr = STDERR
    $stdin = STDIN
    $stdout = STDOUT
    $PROGRAM_NAME = orig_program_name
  end
end

Aruba.configure do |config|
  config.main_class = ThorMain
  config.command_launcher = :in_process
end
