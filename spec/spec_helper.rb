ENV["RAILS_ENV"] ||= "test"
# require 'byebug'

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
  add_filter "/dummy/"
  add_filter "lib/hotglue/version.rb"
  add_filter "lib/generators/hot_glue/templates/capybara_login.rb"
end

require "rails/all"
require 'rails/generators'
require './lib/hot-glue.rb'

# require the gem's core code
Dir["./lib/**/*.rb"].each do |x|
  require(x)
end

require_relative "../dummy/config/application.rb"
require "rspec/rails"
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# https://stackoverflow.com/questions/76319469/when-i-switch-my-rails-open-source-engine-to-postgres-for-testing-i-get-cant
#
# begin
  Dummy::Application.initialize!
# rescue
# end


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
    restore_default_warning_free_config
  }
end

def restore_default_warning_free_config

end
