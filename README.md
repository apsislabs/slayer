![Slayer](https://raw.githubusercontent.com/apsislabs/slayer/master/slayer_logo.png)

# Slayer: A Killer Service Layer

[![Build Status](https://travis-ci.org/apsislabs/slayer.svg?branch=master)](https://travis-ci.org/apsislabs/slayer)

Slayer is intended to operate as a minimal service layer for your ruby application. To achieve this, Slayer provides base classes for business logic.

## Application Structure

Slayer provides 3 base classes for organizing your business logic: `Forms`, `Commands`, and `Services`. Each of these has a distinct role in your application's structure.

### Forms

`Slayer::Forms` are objects for wrapping a set of data, usually to be passed as a parameter to a `Command` or `Service`.

### Commands

`Slayer::Commands` are the bread and butter of your application's business logic. `Commands` are where you compose services, and perform one-off business logic tasks. In our applications, we usually create a single `Command` per `Controller` endpoint.

`Commands` should call `Services`, but `Services` should never call `Commands`.

### Services

`Services` are the building blocks of `Commands`, and encapsulate re-usable chunks of application logic.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slayer'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install slayer
```

## Usage

### Commands

Slayer Commands should implement `call`, which will `pass` or `fail` the service based on input. Commands return a `Slayer::Result` which has a predictable interface for determining `success?` or `failure?`, a `message`, and a `result` payload object.

```ruby
# A Command that passes when given the string "foo"
# and fails if given anything else.
class FooCommand < Slayer::Command
  def call(foo:)
    if foo == "foo"
      pass! result: foo, message: "Passing FooCommand"
    else
      fail! result: foo, message: "Failing FooCommand"
    end
  end
end

result = FooCommand.call(foo: "foo")
result.success? # => true

result = FooCommand.call(foo: "bar")
result.success? # => false
```

### Forms

### Services

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/apsislabs/slayer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
