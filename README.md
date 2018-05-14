![Slayer](https://raw.githubusercontent.com/apsislabs/slayer/master/slayer_logo.png)

# Slayer: A Killer Service Layer

[![Gem Version](https://badge.fury.io/rb/slayer.svg)](https://badge.fury.io/rb/slayer) [![Build Status](https://travis-ci.org/apsislabs/slayer.svg?branch=master)](https://travis-ci.org/apsislabs/slayer) [![Code Climate](https://codeclimate.com/github/apsislabs/slayer/badges/gpa.svg)](https://codeclimate.com/github/apsislabs/slayer) [![Coverage Status](https://coveralls.io/repos/github/apsislabs/slayer/badge.svg)](https://coveralls.io/github/apsislabs/slayer)

Slayer is intended to operate as a minimal service layer for your ruby application. To achieve this, Slayer provides base classes for business logic.

## Application Structure

Slayer provides 3 base classes for organizing your business logic: `Forms`, `Commands`, and `Services`. Each of these has a distinct role in your application's structure.

### Forms

`Slayer::Forms` are objects for wrapping a set of data, usually to be passed as a parameter to a `Command` or `Service`.

### Commands

`Slayer::Commands` are the bread and butter of your application's business logic, and a specific implementation of the `Slayer::Service` object. `Commands` are where you compose services, and perform one-off business logic tasks. In our applications, we usually create a single `Command` per `Controller` endpoint.

`Slayer::Commands` always return a structured `Slayer::Result` object, and when called, enforce handling of both `pass` and `fail` conditions for that result. This helps provide confidence that your core business logic is behaving in expected ways, and helps coerce you to develop in a clean and testable way.

### Services

`Slayer::Service`s are the base class of `Slayer::Command`s, and encapsulate re-usable chunks of application logic. `Services` also return structured `Slayer::Result` objects.

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

Slayer Commands should implement `call`, which will `pass` or `fail` the service based on input. Commands return a `Slayer::Result` which has a predictable interface for determining `success?` or `failure?`, a 'value' payload object, a 'status' value, and a user presentable `message`.

```ruby
# A Command that passes when given the string "foo"
# and fails if given anything else.
class FooCommand < Slayer::Command
  def call(foo:)
    unless foo == "foo"
      flunk! value: foo, message: "Argument must be foo!"
    end

    pass! value: foo
  end
end
```

Handling the results of a command can be done in two ways. The primary way is through a handler block. This block is passed a handler object, which is in turn given blocks to handle different result outcomes:

```ruby
FooCommand.call(foo: "foo") do |m|
  m.pass do |result|
    puts "This code runs on success"
  end

  m.fail do |result|
    puts "This code runs on failure. Message: #{result.message}"
  end

  m.all do
    puts "This code runs on failure or success"
  end

  m.ensure do
    puts "This code always runs after other handler blocks"
  end
end
```

The second is less comprehensive, but can be useful for very simple commands. The `call` method on a `Command` returns its result object, which has statuses set on itself:

```ruby
result = FooCommand.call(foo: "foo")
puts result.success? # => true

result = FooCommand.call(foo: "bar")
puts result.success? # => false
```

Here's a more complex example demonstrating how the command pattern can be used to encapuslate the logic for validating and creating a new user. This example is shown using a `rails` controller, but the same approach can be used regardless of the framework.

```ruby
# commands/user_controller.rb
class CreateUserCommand < Slayer::Command
  def call(create_user_form:)
    unless arguments_valid?(create_user_form)
      flunk! value: create_user_form, status: :arguments_invalid
    end

    user = nil
    transaction do
      user = User.create(create_user_form.attributes)
    end

    unless user.persisted?
      flunk! message: I18n.t('user.create.error'), status: :unprocessible_entity
    end

    pass! value: user
  end

  def arguments_valid?(create_user_form)
    create_user_form.kind_of?(CreateUserForm) &&
      create_user_form.valid? &&
      !User.exists?(email: create_user_form.email)
  end
end

# controllers/user_controller.rb
class UsersController < ApplicationController
  def create
    @create_user_form = CreateUserForm.from_params(create_user_params)

    CreateUserCommand.call(create_user_form: @create_user_form) do |m|
      m.pass do |user|
        auto_login(user)
        redirect_to root_path, notice: t('user.create.success')
      end

      m.fail(:arguments_invalid) do |result|
        flash[:error] = result.errors.full_messages.to_sentence
        render :new, status: :unprocessible_entity
      end

      m.fail do |result|
        flash[:error] = t('user.create.error')
        render :new, status: :bad_request
      end
    end
  end

  private

    def required_user_params
      [:first_name, :last_name, :email, :password]
    end

    def create_user_params
      permitted_params = required_user_params << :password_confirmation
      params.require(:user).permit(permitted_params)
    end
end
```

### Result Matcher

The result matcher is an object that is used to handle `Slayer::Result` objects based on their status.

#### Handlers: `pass`, `fail`, `all`, `ensure`

The result matcher block can take 4 types of handler blocks: `pass`, `fail`, `all`, and `ensure`. They operate as you would expect based on their names.

* The `pass` block runs if the command was successful.
* The `fail` block runs if the command was `flunked`.
* The `all` block runs on any type of result --- `pass` or `fail` --- unless the result has already been handled.
* The `ensure` block always runs after the result has been handled.

#### Handler Params

Every handler in the result matcher block is given three arguments: `value`, `result`, and `command`. These encapsulate the `value` provided in the `pass!` or `flunk!` call from the `Command`, the returned `Slayer::Result` object, and the `Slayer::Command` instance that was just run:

```ruby
class NoArgCommand < Slayer::Command
  def call
    @instance_var = 'instance'
    pass value: 'pass'
  end
end


NoArgCommand.call do |m|
  m.all do |value, result, command|
    puts value # => 'pass'
    puts result.success? # => true
    puts command.instance_var # => 'instance'
  end
endpoint
```

#### Statuses

You can pass a `status` flag to both the `pass!` and `flunk!` methods that allows the result matcher to process different kinds of successes and failures differently:

```ruby
class StatusCommand < Slayer::Command
  def call
    flunk! message: "Generic flunk"
    flunk! message: "Specific flunk", status: :specific_flunk
    flunk! message: "Extra specific flunk", status: :extra_specific_flunk

    pass! message: "Generic pass"
    pass! message: "Specific pass", status: :specific_pass
  end
end

StatusCommand.call do |m|
  m.fail                        { puts "generic fail" }
  m.fail(:specific_flunk)       { puts "specific flunk" }
  m.fail(:extra_specific_flunk) { puts "extra specific flunk" }

  m.pass                        { puts "generic pass" }
  m.pass(:specific_pass)        { puts "specific pass" }
end
```

### Forms

### Services

Slayer Services are objects that should implement re-usable pieces of application logic or common tasks. To prevent circular dependencies Services are required to declare which other Service classes they depend on. If a circular dependency is detected an error is raised.

In order to enforce the lack of circular dependencies, Service objects can only call other Services that are declared in their dependencies.

```ruby
class NetworkService < Slayer::Service
    def self.post()
        ...
    end
end

class StripeService < Slayer::Service
  dependencies NetworkService

  def self.pay()
    ...
    NetworkService.post(url: "stripe.com", body: my_payload)
    ...
  end
end
```

## Rails Integration

While Slayer is independent of any framework, we do offer a first-class integration with Ruby on Rails. To install the Rails extensions, add this line to your application's Gemfile:

```ruby
gem 'slayer_rails'
```

And then execute:

```sh
$ bundle
```

And that's it. The integration provides a small handful of features that make your life easier when working with Ruby on Rails.

### Form Validations

With `slayer_rails`, `Slayer::Form` objects are automatically extended with `ActiveRecord` validations. You can use the same validations you would on your `ActiveRecord` models, but directly on your forms.

### Form Creation

With `slayer_rails` there are two new methods for instantiating `Slayer::Form` objects: `from_params` and `from_model`. These make it easier to populate forms with data while in your Rails controllers.

Take the following example for a `FooController`:

```ruby
class FooController < ApplicationController
  def new
    @foo_form = FooForm.new
  end

  def edit
    @foo = Foo.find(params[:id])
    @foo_form = FooForm.from_model(@foo)
  end

  def create
    @foo_form = FooForm.from_params(foo_params)
  end

  def update
    @foo_form = FooForm.from_params(foo_params)
  end

  private

    def foo_params
      params.require(:foo).permit(:bar, :baz)
    end
end
```

### Transactions

`Slayer::Command` and `Slayer::Service` objects are extended with access to `ActiveRecord` transactions. Anywhere in your `Command` or `Service` objects, you can execute a `transaction` block, which will let you bundle database interactions.

```ruby
class FooCommand < Slayer::Command
  def call
    transaction do
      # => database interactions
    end
  end
end
```

### Generators

Use generators to make sure your `Slayer` objects are always in the right place. `slayer_rails` includes generators for `Slayer::Form`, `Slayer::Command`, and `Slayer::Service` objects.

```sh
$ bin/rails g slayer:form foo_form
$ bin/rails g slayer:command foo_command
$ bin/rails g slayer:service foo_service
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To generate documentation run `yard`. To view undocumented files run `yard stats --list-undoc`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/apsislabs/slayer.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
