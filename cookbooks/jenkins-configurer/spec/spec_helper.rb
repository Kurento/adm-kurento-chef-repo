require 'chefspec'

RSpec.configure do |config|
  config.tty = true
  config.formatter = :documentation
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.platform = 'ubuntu'
  config.version = '14.04'
end
