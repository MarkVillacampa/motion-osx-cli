unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

require_relative 'project/motion-osx-cli'

lib_dir_path = File.dirname(File.expand_path(__FILE__))
Motion::Project::App.setup do |app|
  app.frameworks = ['Foundation']

  platform = app.respond_to?(:template) ? app.template : :ios
  if platform != :osx
    raise <<EOS
motion-osx-cli helps you create command line apps for OSX and does not work on iOS.
Make sure you are requiring the OSX template in your Rakefile:

require 'motion/project/template/osx'

EOS
  end
end
