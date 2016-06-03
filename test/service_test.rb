require 'test_helper'

# Tests below rely on FooService to be implemented. FooService
# is a simple service which passes when given the keyword argument
# `foo: "Foo"` and fails when given any other argument.

class Slayer::ServiceTest < Minitest::Test
  def test_returns_result_on_pass
    result = FooService.call(foo: "foo")
    assert result.is_a? Slayer::Result
  end

  def test_returns_result_on_fail
    result = FooService.call(foo: "bar")
    assert result.is_a? Slayer::Result
  end

  def test_result_has_expected_properties_on_pass
    result = FooService.call(foo: "foo")

    assert_equal result.message, "Passing FooService"
    assert_equal result.result, "foo"
    assert result.success?
  end

  def test_result_has_expected_properties_on_fail
    result = FooService.call(foo: "bar")

    assert_equal result.message, "Failing FooService"
    assert_equal result.result, "bar"
    refute result.success?
  end

  def test_can_be_run_with_exceptions_flag
    result = FooService.new.run!(foo: "foo")

    assert_equal result.message, "Passing FooService"
    assert_equal result.result, "foo"
    assert result.success?
  end

  def test_raises_error_for_failed_test
    assert_raises Slayer::ServiceFailure do
      FooService.new.run!(foo: "bar")
    end
  end

  def test_raises_error_for_incorrect_args
    assert_raises ArgumentError do
      FooService.call(bar: "foo")
    end
  end

  def test_raises_error_for_invalid_service
    assert_raises Slayer::ServiceNotImplemented do
      NotImplementedService.call
    end

    assert_raises NotImplementedError do
      InvalidService.call
    end
  end
end
