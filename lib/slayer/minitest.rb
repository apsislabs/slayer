# :nocov:
require 'minitest/assertions'
# rubocop:disable Metrics/MethodLength
module Minitest::Assertions
  def assert_ok(result, status: nil, message: nil, value: nil)
    assert result.ok?, 'Expected command to succeed.'

    unless status.nil?
      assert_equal(
        status,
        result.status,
        "Expected command to succeed with status: :#{status}, got: :#{result.status}"
      )
    end

    unless message.nil?
      assert_equal(
        message,
        result.message,
        "Expected command to succeed with message: #{message}, got: #{result.message}"
      )
    end

    unless value.nil?
      assert_equal(
        value,
        result.value,
        "Expected command to succeed with value: #{value}, got: #{result.value}"
      )
    end
  end
  alias assert_success assert_ok
  alias refute_err assert_ok
  alias refute_failed assert_ok

  def refute_ok(result, status: nil, message: nil, value: nil)
    refute result.ok?, 'Expected command to fail.'

    unless status.nil?
      refute_equal(
        status,
        result.status,
        "Expected command to fail with status: :#{status}, got: :#{result.status}"
      )
    end

    unless message.nil?
      refute_equal(
        message,
        result.message,
        "Expected command to fail with message: #{message}, got: #{result.message}"
      )
    end

    unless value.nil?
      refute_equal(
        value,
        result.value,
        "Expected command to fail with value: #{value}, got: #{result.value}"
      )
    end
  end
  alias assert_err refute_ok
  alias assert_failed refute_ok
  alias refute_success refute_ok
end
# rubocop:enable Style/Documentation
# rubocop:enable Metrics/MethodLength
# :nocov:
