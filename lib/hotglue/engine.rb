module HotGlue
  class Engine < ::Rails::Engine

    config.autoload_paths << File.expand_path("lib/helpers/hot_glue_helper.rb", __dir__)
  end
end
