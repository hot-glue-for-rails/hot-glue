

module HotGlue
  class DirectUploadInstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def filepath_prefix
      # todo: inject the context
      'spec/dummy/' if Rails.env.test?
    end

    def initialize(*args) #:nodoc:
      super

      if Gem::Specification.sort_by{ |g| [g.name.downcase, g.version] }.group_by{ |g| g.name }['importmap-rails'] # impomrtmaps

        file_contents = File.read("#{filepath_prefix}app/javascript/application.js")

        if !file_contents.include?("//= require activestorage")
          file_contents << "//= require activestorage"
          File.write("#{filepath_prefix}app/javascript/application.js", file_contents)
          puts "  HOTGLUE --> added to #{filepath_prefix}app/javascript/application.js: `//= require activestorage"
        else
          puts "  HOTGLUE --> #{filepath_prefix}app/javascript/application.js already contains `//= require activestorage`"
        end

      elsif Gem::Specification.sort_by{ |g| [g.name.downcase, g.version] }.group_by{ |g| g.name }['jsbundling-rails']
        file_contents = File.read("#{filepath_prefix}app/javascript/application.js")

        if !file_contents.include?("ActiveStorage.start()")
          file_contents << "import * as ActiveStorage from \"@rails/activestorage\"
ActiveStorage.start()"
          File.write("#{filepath_prefix}app/javascript/application.js", file_contents)
          puts "  HOTGLUE --> added to #{filepath_prefix}app/javascript/application.js: `ActiveStorage.start()"
        else
          puts "  HOTGLUE --> #{filepath_prefix}app/javascript/application.js already contains `ActiveStorage.start()`"
        end


      else
        puts "  HOTGLUE --> could not detect either importmap-rails or jsbundling-rails app"
      end
    end
  end
end



