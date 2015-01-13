$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec/given'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |c|
  c.filter_run_excluding pending: true
end
