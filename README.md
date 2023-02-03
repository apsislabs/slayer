![Slayer](https://raw.githubusercontent.com/apsislabs/slayer/master/slayer_logo.png)

# Slayer: A Killer Service Layer

[![Gem Version](https://badge.fury.io/rb/slayer.svg)](https://badge.fury.io/rb/slayer) [![Build Status](https://travis-ci.org/apsislabs/slayer.svg?branch=master)](https://travis-ci.org/apsislabs/slayer) [![Code Climate](https://codeclimate.com/github/apsislabs/slayer/badges/gpa.svg)](https://codeclimate.com/github/apsislabs/slayer) [![Coverage Status](https://coveralls.io/repos/github/apsislabs/slayer/badge.svg)](https://coveralls.io/github/apsislabs/slayer)

Slayer is intended to operate as a minimal service layer for your ruby application. To achieve this, Slayer provides base classes for business logic.

**Slayer is still under development, and not yet ready for production use. We are targetting a stable API with the 0.4.0 launch, so expect breaking changes until then.**

## Application Structure

Slayer provides 2 base classes for organizing your business logic: `Forms` and `Commands`. These each have a distinct role in your application's structure.

### Forms

`Slayer::Forms` are objects for wrapping a set of data, usually to be passed as a parameter to a `Command` or `Service`.

### Commands

`Slayer::Commands` are the bread and butter of your application's business logic. `Commands` wrap logic into easily tested, isolated, composable classes. In our applications, we usually create a single `Command` per `Controller` endpoint.

`Slayer::Commands` must implement a `call` method, which always return a structured `Slayer::Result` object making operating on results straightforward. The `call` method can also take a block, which provides `Slayer::ResultMatcher` object, and enforces handling of both `pass` and `fail` conditions for that result.

This helps provide confidence that your core business logic is behaving in expected ways, and helps coerce you to develop in a clean and testable way.

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

Slayer Commands should implement `call`, which will `pass` or `fail` the service based on input. Commands return a `Slayer::Result` which has a predictable interface for determining `passed?` or `failed?`, a 'value' payload object, a 'status' value, and a user presentable `message`.

```ruby
# A Command that passes when given the string "foo"
# and fails if given anything else.
class FooCommand < Slayer::Command
  def call(foo:)
    unless foo == "foo"
      return err value: foo, message: "Argument must be foo!"
    end

    ok value: foo
  end
end
```

Handling the results of a command can be done in two ways. The primary way is through a handler block. This block is passed a handler object, which is in turn given blocks to handle different result outcomes:

```ruby
FooCommand.call(foo: "foo") do |m|
  m.ok do |value|
    puts "This code runs on success"
  end

  m.err do |_value, result|
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
puts result.ok? # => true

result = FooCommand.call(foo: "bar")
puts result.ok? # => false
```

Here's a more complex example demonstrating how the command pattern can be used to encapuslate the logic for validating and creating a new user. This example is shown using a `rails` controller, but the same approach can be used regardless of the framework.

```ruby
# commands/user_controller.rb
class CreateUserCommand < Slayer::Command
  def call(create_user_form:)
    unless arguments_valid?(create_user_form)
      return err value: create_user_form, status: :arguments_invalid
    end

    user = nil
    transaction do
      user = User.create(create_user_form.attributes)
    end

    unless user.persisted?
      return err message: I18n.t('user.create.error'), status: :unprocessible_entity
    end

    ok value: user
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
      m.ok do |user|
        auto_login(user)
        redirect_to root_path, notice: t('user.create.success')
      end

      m.err(:arguments_invalid) do |_user, result|
        flash[:error] = result.errors.full_messages.to_sentence
        render :new, status: :unprocessible_entity
      end

      m.err do |_user, result|
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

#### Handlers: `ok`, `err`, `all`, `ensure`

The result matcher block can take 4 types of handler blocks: `ok`, `err`, `all`, and `ensure`. They operate as you would expect based on their names.

* The `ok` block runs if the command was successful.
* The `err` block runs if the command was `koed`.
* The `all` block runs on any type of result --- `ok` or `err` --- unless the result has already been handled.
* The `ensure` block always runs after the result has been handled.

#### Handler Params

Every handler in the result matcher block is given three arguments: `value`, `result`, and `command`. These encapsulate the `value` provided in the `ok` or `return err` call from the `Command`, the returned `Slayer::Result` object, and the `Slayer::Command` instance that was just run:

```ruby
class NoArgCommand < Slayer::Command
  def call
    @instance_var = 'instance'
    ok value: 'pass'
  end
end


NoArgCommand.call do |m|
  m.all do |value, result, command|
    puts value # => 'pass'
    puts result.ok? # => true
    puts command.instance_var # => 'instance'
  end
end
```

#### Statuses

You can pass a `status` flag to both the `ok` and `return err` methods that allows the result matcher to process different kinds of successes and failures differently:

```ruby
class StatusCommand < Slayer::Command
  def call
    return err message: "Extra specific ko", status: :extra_specific_err if extra_specific_err?
    return err message: "Specific ko", status: :specific_err if specific_err?
    return err message: "Generic ko" if generic_err?

    return ok message: "Specific pass", status: :specific_pass if specific_pass?

    ok message: "Generic pass"
  end
end

StatusCommand.call do |m|
  m.err                         { puts "generic err" }
  m.err(:specific_err)          { puts "specific err" }
  m.err(:extra_specific_err)    { puts "extra specific err" }

  m.ok                          { puts "generic pass" }
  m.ok(:specific_pass)          { puts "specific pass" }
end
```

## RSpec & Minitest Integrations

`Slayer` provides assertions and matchers that make testing your `Commands` simpler.

### RSpec

To use with RSpec, update your `spec_helper.rb` file to include:

`require 'slayer/rspec'`

This provides you with two new matchers: `be_successful_result` and `be_failed_result`, both of which can be chained with a `with_status`, `with_message`, or `with_value` expectations:

```ruby
RSpec.describe RSpecCommand do
  describe '#call' do
    context 'should pass' do
      subject(:result) { RSpecCommand.call(should_pass: true) }

      it { is_expected.to be_success_result }
      it { is_expected.not_to be_failed_result }
      it { is_expected.to be_success_result.with_status(:no_status) }
      it { is_expected.to be_success_result.with_message("message") }
      it { is_expected.to be_success_result.with_value("value") }
    end

    context 'should fail' do
      subject(:result) { RSpecCommand.call(should_pass: false) }

      it { is_expected.to be_failed_result }
      it { is_expected.not_to be_success_result }
      it { is_expected.to be_failed_result.with_status(:no_status) }
      it { is_expected.to be_failed_result.with_message("message") }
      it { is_expected.to be_failed_result.with_value("value") }
    end
  end
end
```

### Minitest

To use with Minitest, update your 'test_helper' file to include:

`require slayer/minitest`

This provides you with new assertions: `assert_success` and `assert_failed`:

```ruby
require "minitest/autorun"

class MinitestCommandTest < Minitest::Test
  def setup
    @success_result = MinitestCommand.call(should_pass: true)
    @failed_result = MinitestCommand.call(should_pass: false)
  end

  def test_is_ok
    assert_success @success_result, status: :no_status, message: 'message', value: 'value'
    refute_failed @success_result, status: :no_status, message: 'message', value: 'value'
  end

  def test_is_err
    assert_failed @failed_result, status: :no_status, message: 'message', value: 'value'
    refute_success @failed_result, status: :no_status, message: 'message', value: 'value'
  end
end
```

**Note:** There is no current integration for `Minitest::Spec`.

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

Use generators to make sure your `Slayer` objects are always in the right place. `slayer_rails` includes generators for `Slayer::Form` and `Slayer::Command`.

```sh
$ bin/rails g slayer:form foo_form
$ bin/rails g slayer:command foo_command
```

## Compatability

Backwards compatability with previous versions requires additional includes.

```ruby
require 'slayer/compat/compat_040'
```

If you use test matchers, you will have to separately require the compatability layer for your test runner:

```ruby
require 'slayer/compat/minitest_compat_040'

# OR

require 'slayer/compat/rspec_compat_040'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To generate documentation run `yard`. To view undocumented files run `yard stats --list-undoc`.

### Development w/ Docker

    $ docker-compose up
    $ bin/ssh_to_container
    $ bin/console

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/apsislabs/slayer.

Any PRs should be accompanied with documentation in `README.md`, and changes documented in [`CHANGELOG.md`](https://keepachangelog.com/).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

---

# Built by Apsis

[![apsis](https://s3-us-west-2.amazonaws.com/apsiscdn/apsis.png)](https://www.apsis.io)

`slayer` was built by Apsis Labs. We love sharing what we build! Check out our [other libraries on Github](https://github.com/apsislabs), and if you like our work you can [hire us](https://www.apsis.io/work-with-us/) to build your vision.
