ENV["RAILS_ENV"] ||= "test"
require 'byebug'


if( ENV['COVERAGE'] == 'on' )
  require 'simplecov'
  require 'simplecov-rcov'
  class SimpleCov::Formatter::MergedFormatter
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result)
      SimpleCov::Formatter::RcovFormatter.new.format(result)
    end
  end
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
  SimpleCov.start 'rails' do
    add_filter "/vendor/"
    add_filter "/test/"
  end
end

# require rails first
require "rails/all"
require 'rails/generators'
# require the gem's core code
Dir["rails/generators/*.rb"].each do |x|
  puts "requiring #{x}"
  require(x)
end

# require the gem's core code
Dir["./lib/**/*.rb"].each do |x|
  require(x)
end


require "dummy/application"

require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

Dummy::Application.initialize!



RSpec.configure do |config|

  config.infer_spec_type_from_file_location!
  config.order = :random
  config.use_transactional_fixtures = true

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end



  config.before {
    # note that because the object persist in memory accross test runs
    # (unlike database transactions), it must be reset for each
    # test run in order for the tests that disable any given feature
    # not to affect the tests after them
    # any testing for disabled should be done in-test, after this hook has run
    #


    restore_default_warning_free_config
  }

  require 'rails-controller-testing'
  config.include Rails::Controller::Testing::TestProcess
  config.include Rails::Controller::Testing::TemplateAssertions
  config.include Rails::Controller::Testing::Integration
end




def restore_default_warning_free_config

end
