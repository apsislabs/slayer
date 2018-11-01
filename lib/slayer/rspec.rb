require 'rspec/expectations'

RSpec::Matchers.define :be_success_result do
  match(&:success?)

  chain :with_status do |status|
    @status = status
  end

  failure_message do |result|
    return 'expected command to succeed' if @status.nil?
    return "expected command to succeed with status :#{@status}, but got :#{result.status}"
  end

  failure_message_when_negated do |result|
    return "expected command not to have status :#{@status}" if @status.present? && result.status == @status
    return 'expected command to fail'
  end
end

RSpec::Matchers.define :be_failed_result do
  match do |result|
    return result.failure? if @status.nil?
    return result.failure? && (result.status == @status)
  end

  chain :with_status do |status|
    @status = status
  end

  failure_message do |result|
    return 'expected command to fail' if @status.nil?
    return "expected command to fail with status :#{@status}, but got :#{result.status}"
  end

  failure_message_when_negated do |result|
    return "expected command not to have status :#{@status}" if @status.present? && result.status == @status
    return 'expected command to succeed'
  end
end
