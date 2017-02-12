![Slayer](https://raw.githubusercontent.com/apsislabs/slayer/master/slayer_logo.png)

# Slayer: A Service Layer

[![Gem Version](https://badge.fury.io/rb/slayer.svg)](https://badge.fury.io/rb/slayer) [![Build Status](https://travis-ci.org/apsislabs/slayer.svg?branch=master)](https://travis-ci.org/apsislabs/slayer) [![Code Climate](https://codeclimate.com/github/apsislabs/slayer/badges/gpa.svg)](https://codeclimate.com/github/apsislabs/slayer)

Slayer is intended to operate as a minimal service layer for your ruby application. To achieve this, Slayer provides base classes for writing small, composable services, which should behave as [pure functions](https://en.wikipedia.org/wiki/Pure_function).

Slayer Services should implement `call`, which will `pass` or `fail` the service based on input. Services return a `Slayer::Result` which has a predictable interface for determining `success?` or `failure?`, a `message`, and a `result`.

Services are composed by Composers, which describe the order and arguments for running a number of Services in sequence. If any of these Services fail, those run before it are rolled back by calling `rollback` on the service, passing the service its `result` object, and the original parameters.

Composers also return a `Slayer::Result` object, which has as its `result` parameter a hash of the result objects from its composed services.

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
# A service that passes when given the string "foo"
# and fails if given anything else.
class FooService < Slayer::Service
    def call(foo:)
      if foo == "foo"
        pass! result: foo, message: "Passing FooService"
      else
        fail! result: foo, message: "Failing FooService"
      end
    end
end

# A placeholder service that always passes with returned result
# as the argument passed into it.
class BarService < Slayer::Service
    def call(bar:)
        pass! result: bar, message: "Passing BarService"
    end
end

# A simple composer which composes the FooService and BarService
class FooBarComposer < Slayer::Composer
    compose FooService, BarService

    def call
        pass! result: @results,  message: "Yay!"
    end

    def foo_service_args
        return { foo: @composer_params[:foo] }
    end

    def bar_service_args
        return { bar: foo_service_results.message }
    end
end


result = FooBarComposer.call(foo: "Jim", bar: "Joe")
result.success? # => true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/apsislabs/slayer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
