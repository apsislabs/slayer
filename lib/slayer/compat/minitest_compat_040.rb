# :nocov:

require "minitest/assertions"

module Minitest::Assertions
  alias_method :assert_success, :assert_ok
  alias_method :refute_failed, :assert_ok
  alias_method :assert_failed, :refute_ok
  alias_method :refute_success, :refute_ok
end

# :nocov:
