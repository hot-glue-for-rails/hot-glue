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

# FileUtils.rm_rf("spec/dummy/spec/")

require 'rails/generators'

# require the gem's core code
# Dir["lib/generators/**/*.rb"].each do |x|
#   puts "requiring #{x}"
#   require(x)
# end

# require the gem's core code
require "./lib/hot-glue.rb"


Dir["./lib/**/*.rb"].each do |x|
  puts "requiring #{x}"
  require(x)
end



require_relative "./dummy/config/application.rb"

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

  }
end
