require 'spec_helper'

describe 'consul_stockpile', type: :aruba do
  describe 'help' do
    it 'runs' do
      run('consul_stockpile help')
      expect(last_command_started).to have_output include_output_string 'consul_stockpile help [COMMAND]'
    end
  end

  describe 'start' do
  end
end
