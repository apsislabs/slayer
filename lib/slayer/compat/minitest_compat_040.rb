# :nocov:

require 'minitest/assertions'

module Minitest::Assertions
  alias assert_success assert_ok
  alias refute_failed assert_ok
  alias assert_failed refute_ok
  alias refute_success refute_ok
end

# :nocov:
