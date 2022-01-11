$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "hotglue/version"
# require 'byebug'
# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "hot-glue"
  spec.version     = HotGlue::VERSION
  spec.license     = 'Commercial with free option'
  spec.date        = Time.now.strftime("%Y-%m-%d")
  spec.summary     = "A gem to build Tubro Rails scaffolding."
  spec.description = "Simple, plug & play Rails scaffold building companion for Turbo-Rails and Hotwire"
  spec.authors     = ["Jason Fleetwood-Boldt"]
  spec.email       = 'code@jasonfb.net'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.

  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)}) || f.match(%r{(gemspec|gem)$}) }
    files
  end

  spec.add_runtime_dependency "rails",  '> 5.1'
  spec.homepage    = 'https://jfb.teachable.com/p/hot-glue-in-depth-tutorial?utm_source=rubygems.org&utm_campaign=rubygems_link'
  spec.metadata    = { "source_code_uri" => "https://github.com/jasonfb/hot-glue" }
  spec.add_runtime_dependency('kaminari', '~> 1.2')
  spec.add_runtime_dependency('sass-rails')

  spec.add_dependency 'ffaker', "~> 2.16"

  spec.post_install_message = <<~MSG
    ---------------------------------------------
    Welcome to Hot Glue - A Scaffold Building Companion for Hotwire + Turbo-Rails
    For license options visit https://heliosdev.shop/hot-glue-license
    ---------------------------------------------
  MSG
end
