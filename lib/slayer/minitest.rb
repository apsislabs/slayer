# :nocov:
require 'minitest/assertions'

module Minitest::Assertions
  def assert_success(result, status: nil, message: nil, value: nil)
    assert result.success?, "Expected command to succeed."

    assert_equal(status, result.status, "Expected command to succeed with status: :#{status}, got: :#{result.status}") unless status.nil?
    assert_equal(message, result.message, "Expected command to succeed with message: #{message}, got: #{result.message}") unless message.nil?
    assert_equal(value, result.value, "Expected command to succeed with value: #{value}, got: #{result.value}") unless value.nil?
  end
  alias refute_failed assert_success

  def refute_success(result, status: nil, message: nil, value: nil)
    refute result.success?, "Expected command to fail."

    refute_equal(status, result.status, "Expected command to fail with status: :#{status}, got: :#{result.status}") unless status.nil?
    refute_equal(message, result.message, "Expected command to fail with message: #{message}, got: #{result.message}") unless message.nil?
    refute_equal(value, result.value, "Expected command to fail with value: #{value}, got: #{result.value}") unless value.nil?
  end
  alias assert_failed refute_success
end
# :nocov:
