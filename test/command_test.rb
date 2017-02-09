require 'test_helper'

# Tests below rely on FooCommand to be implemented. FooCommand
# is a simple service which passes when given the keyword argument
# `foo: "Foo"` and fails when given any other argument.

class Slayer::CommandTest < Minitest::Test
  def test_returns_result_on_pass
    result = FooCommand.call(foo: "foo")
    assert result.is_a? Slayer::Result
  end

  def test_returns_result_on_fail
    result = FooCommand.call(foo: "bar")
    assert result.is_a? Slayer::Result
  end

  def test_result_has_expected_properties_on_pass
    result = FooCommand.call(foo: "foo")

    assert_equal result.message, "Passing FooCommand"
    assert_equal result.result, "foo"
    assert result.success?
  end

  def test_result_has_expected_properties_on_fail
    result = FooCommand.call(foo: "bar")

    assert_equal result.message, "Failing FooCommand"
    assert_equal result.result, "bar"
    refute result.success?
  end

  def test_can_be_run_with_exceptions_flag
    result = FooCommand.new.run!(foo: "foo")

    assert_equal result.message, "Passing FooCommand"
    assert_equal result.result, "foo"
    assert result.success?
  end

  def test_raises_error_for_failed_test
    assert_raises Slayer::CommandFailure do
      FooCommand.new.run!(foo: "bar")
    end
  end

  def test_raises_error_for_incorrect_args
    assert_raises ArgumentError do
      FooCommand.call(bar: "foo")
    end
  end

  def test_raises_error_for_invalid_service
    assert_raises Slayer::CommandNotImplemented do
      NotImplementedCommand.call
    end

    assert_raises NotImplementedError do
      InvalidCommand.call
    end
  end
end
