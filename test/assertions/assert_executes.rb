require 'minitest/assertions'

module Minitest::Assertions

  def assert_executes(exactly: nil,
                      at_least: nil,
                      message: 'The given block did not execute the desired statement',
                      &block)

    assert_proc = Proc.new { |a,m| assert(a,m) }
    internal_assert_executes(assert_method: assert_proc, message: message, exactly: exactly, at_least: at_least, &block)
  end

  def refute_executes(exactly: nil,
                      at_least: nil,
                      message: 'The given block executed the statement it should not have executed',
                      &block)

    refute_proc = Proc.new { |a,m| refute(a,m) }
    internal_assert_executes(assert_method: refute_proc, message: message, exactly: exactly, at_least: at_least, &block)
  end

  alias assert_not_executes refute_executes
  alias refute_not_executes assert_executes # please nobody ever use this.

  def executes
    @assert_executes_stack[-1] = @assert_executes_stack[-1] + 1
  end

  private

  def internal_assert_executes(assert_method:, message:, exactly: nil, at_least: nil)
    @assert_executes_stack ||= []
    @assert_executes_stack << 0

    yield

    at_least = 1 if (!exactly && !at_least)
    value = @assert_executes_stack.pop

    assert_method.call(value == exactly, message) if exactly
    assert_method.call(value >= at_least, message) if at_least
  end
end
