# Slayer
## A Service Layer

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slayer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slayer

## Usage

```ruby
class FooService < Slay::Service
    def call(foo:)
        puts "Hello #{foo}"
        return pass!
    end
end

class BarService < Slay::Service
    def call(bar:)
        puts "Goodbye #{bar}"
        return pass!
    end
end

class FooBarOrganizer < Slay::Organizer
    organize FooService, BarService

    # Args Passed to FooService
    def foo_service_args
        return { foo: @organizer_params[:foo] }
    end

    # Args Passed to BarService
    def bar_service_args
        return { bar: @organizer_params[:bar] }
    end
end

FooBarOrganizer.call(foo: "Jim", bar: "Joe")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/apsislabs/slayer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
