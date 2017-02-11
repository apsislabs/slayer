require 'test_helper'

# Tests below rely on ArgCommand to be implemented. ArgCommand
# is a simple service which passes when given the keyword argument
# `arg: "Foo"` and fails when given any other argument.

class Slayer::CommandTest < Minitest::Test

  def test_instantiates_and_calls_expected_methods
    NoArgCommand.expects(:call).once
    NoArgCommand.call()
  end

  def test_instantiates_and_calls_with_exceptions_flag
    NoArgCommand.expects(:call!).once
    NoArgCommand.call!()
  end

  # Implementation Tests
  # ---------------------------------------------
  #
  # The following unit tests test simple Implementations
  # of the Command interface for correctness. They rely
  # on the Command objects defined in the fixtures
  # directory for correctness.

  def test_executes_block_passed_to_command
    @truthy = false
    NoArgCommand.call do |r, c|
      @truthy = true
    end

    assert_equal true, @truthy
  end

  def test_result_and_command_available_in_block
    NoArgCommand.call do |r, c|
      assert c.is_a? NoArgCommand

      assert r.is_a? Slayer::Result
      assert_equal true, r.success?
    end
  end

  def test_returns_result_on_pass
    result = ArgCommand.call(arg: "arg")
    assert result.is_a? Slayer::Result
  end

  def test_returns_result_on_fail
    result = ArgCommand.call(arg: nil)
    assert result.is_a? Slayer::Result
  end

  def test_result_has_expected_properties_on_pass
    result = ArgCommand.call(arg: "arg")

    assert_equal result.result, "arg"
    assert result.success?
  end

  def test_result_has_expected_properties_on_fail
    result = ArgCommand.call(arg: nil)

    assert_equal result.result, nil
    refute result.success?
  end

  def test_can_be_run_with_exceptions_flag
    result = ArgCommand.call!(arg: "arg")

    assert_equal result.result, "arg"
    assert result.success?
  end

  def test_raises_error_for_run_with_exceptions_flag
    assert_raises Slayer::CommandFailure do
      ArgCommand.call!(arg: nil)
    end
  end

  def test_raises_error_for_incorrect_args
    assert_raises ArgumentError do
      ArgCommand.call(bar: "arg")
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