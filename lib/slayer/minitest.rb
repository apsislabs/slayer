# :nocov:
require 'minitest/assertions'
# rubocop:disable Style/Documentation
# rubocop:disable Metrics/MethodLength
module Minitest::Assertions
  def assert_success(result, status: nil, message: nil, value: nil)
    assert result.success?, 'Expected command to succeed.'

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
  alias refute_failed assert_success

  def refute_success(result, status: nil, message: nil, value: nil)
    refute result.success?, 'Expected command to fail.'

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
  alias assert_failed refute_success
end
# rubocop:enable Style/Documentation
# rubocop:enable Metrics/MethodLength
# :nocov:
