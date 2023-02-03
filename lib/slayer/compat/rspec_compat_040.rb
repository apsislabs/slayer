# :nocov:

require 'rspec/expectations'

RSpec::Matchers.alias_matcher :be_failed_result, :be_err_result
RSpec::Matchers.alias_matcher :be_success_result, :be_ok_result

# :nocov:
