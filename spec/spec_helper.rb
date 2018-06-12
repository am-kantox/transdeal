require 'bundler/setup'
require 'pry'

require 'transdeal'

require_relative 'spec_ar_helper'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Object.send(:remove_const, 'Master') if Kernel.const_defined?('Master')
class Master < ActiveRecord::Base
  has_one :slave
end

Object.send(:remove_const, 'Slave') if Kernel.const_defined?('Slave')
class Slave < ActiveRecord::Base
  belongs_to :master
end

Object.send(:remove_const, 'Partial') if Kernel.const_defined?('Partial')
class Partial < ActiveRecord::Base
end

Object.send(:remove_const, 'CallbackHandler') if Kernel.const_defined?('CallbackHandler')
class CallbackHandler
  def self.run(data)
    puts data.inspect
  end
end
