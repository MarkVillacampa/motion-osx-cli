# motion-osx-cli

This gem helps you create command line tools for OSX using RubyMotion.

## Installation

Add this line to your application's Gemfile:

    gem 'motion-osx-cli'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motion-osx-cli

And add this line to your Rakefile:

    require 'motion-osx-cli'

## Usage

Define a `main` method in your AppDelegate class which will be the main entry point for your application.

```Ruby
class AppDelegate
  def main(argc, argv)
    # your code
  end
end
```

You can pass arguments to your app when executing it on the command line. `argc` is an integer representing the number of arguments passed to your application, and `argv` is an array containing each of these arguments. Let's see an example:

```Ruby
class AppDelegate
  def main(argc, argv)
    puts "Number of arguments:"
    p argc
    puts "Arguments:"
    p argv
  end
end
```

```
$ /Users/me/Desktop/my-app hello world
Number of arguments:
3
Arguments:
["/Users/me/Desktop/my-app", "hello", "world"]
```

As you can see, even if we don't pass any arguments, the first argument will always be the full path of the file we're executing. This is a standard behaviour for any command line application.

## Frameworks

By default, your app will only require the `Foundation` framework, which is required by the Rubymotion runtime. If you want to include other frameworks you can do so in your Rakefile:

```Ruby
Motion::Project::App.setup do |app|
  app.frameworks << 'AppKit'
end
```

If you want to add some UI to your application, you will need to create a NSApplication:

```Ruby
class AppDelegate
  def main(argc, argv)
    app = NSApplication.sharedApplication
    app.delegate = self
    NSApp.run
  end

  def applicationDidFinishLaunching(notification)
    # This will be executed after NSApp.run
  end
end
```

## Distribution

When the Rubymotion toolchain builds your application, it will generate a .app file. However in the case of a command line application we are only interested in the executable. To retrieve it, right click in the .app file and click `Show Package Contents`. The executable will be located in a path similar to this, inside your `build` directory:

    build/MacOSX-10.9-Release/my-app.app/Contents/MacOS/my-app

You can now copy it somewhere else and execute it on your terminal.

If you don't have an OSX Developer Cetificate, or you simply don't want to codesign your command line app, you can do so in your Rakefile

```Ruby
Motion::Project::App.setup do |app|
  app.codesign_for_release = false
end
```

## Testing

If your app does does not require the AppKit framework and doesn't call `NSApp.run` at any point, `rake spec` will fail. Currently, Rubymotion's test framework expects a run loop to be created by a NSApplication.

## TODO

- Find a way to make tests work.
- Create a Rubymotion template.
- Patch the toolchain to only create the executable and not the .app

## Thanks

  Thanks to [Jack Chen](http://twitter.com/chendo) for his article [Building a Command Line OS X app with RubyMotion](http://chen.do/blog/2013/10/04/building-a-command-line-os-x-app-with-rubymotion/) which saved me a lot of detective work.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
