module HotGlue
  class DropzoneInstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def initialize(*args) #:nodoc:
      super
      system("./bin/rails generate stimulus Dropzone")
      copy_file "javascript/dropzone_controller.js", "app/javascript/controllers/dropzone_controller.js"
      puts "HOT GLUE --> copying dropzone stimulus controller into app/javascript/controllers/dropzone_controller.js"


      if File.exist?("app/assets/stylesheets/application.bootstrap.scss")
        scss_file = "app/assets/stylesheets/application.bootstrap.scss"
      elsif File.exist?("app/assets/stylesheets/application.scss")
        scss_file = "app/assets/stylesheets/application.scss"
      else
        raise "Could not detect your stylesheet, aborting..."
      end

      file_contents = File.read(scss_file)

      if !file_contents.include?("@import \"dropzone/dist/dropzone\"")
        file_contents << "\n@import \"dropzone/dist/dropzone\";\n@import \"dropzone/dist/basic\";"


        File.write(scss_file, file_contents)

        puts "  HOTGLUE --> added to #{scss_file}: @import dropzone ... "
      else
        puts "  HOTGLUE --> #{scss_file} already contains @import dropzone"
      end


    end
  end
end



