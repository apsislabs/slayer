require 'rspec/expectations'

RSpec::Matchers.define :be_success_result do
  match(&:success?)

  chain :with_status do |status|
    @status = status
  end

  chain :with_message do |message|
    @message = message
  end

  chain :with_value do |value|
    @value = value
  end

  # :nocov:
  failure_message do |result|
    return 'expected command to succeed' if @status.nil? && @value.nil? && @message.nil?
    return "expected command to succeed with status: :#{@status}, but got: :#{result.status}" unless @status.nil?
    return "expected command to succeed with value: #{@value}, but got: #{result.value}" unless @value.nil?
    return "expected command to succeed with message: #{@message}, but got: :#{result.message}" unless @message.nil?
  end

  failure_message_when_negated do |result|
    return "expected command not to have message: #{@message}" if !@message.nil? && result.message == @message
    return "expected command not to have value: #{@value}" if !@value.nil? && result.value == @value
    return "expected command not to have status :#{@status}" if !@status.nil? && result.status == @status
    return 'expected command to fail'
  end
  # :nocov:
end

RSpec::Matchers.define :be_failed_result do
  match do |result|
    return result.failure? if @status.nil?
    return result.failure? && (result.status == @status)
  end

  chain :with_status do |status|
    @status = status
  end

  chain :with_message do |message|
    @message = message
  end

  chain :with_value do |value|
    @value = value
  end

  # :nocov:
  failure_message do |result|
    return 'expected command to fail' if @status.nil? && @value.nil? && @message.nil?
    return "expected command to fail with status: :#{@status}, but got: :#{result.status}" unless @status.nil?
    return "expected command to fail with value: #{@value}, but got: #{result.value}" unless @value.nil?
    return "expected command to fail with message: #{@message}, but got: :#{result.message}" unless @message.nil?
  end

  failure_message_when_negated do |result|
    return "expected command to have message: #{@message}" if !@message.nil? && result.message == @message
    return "expected command to have value: #{@value}" if !@value.nil? && result.value == @value
    return "expected command to have status :#{@status}" if !@status.nil? && result.status == @status
    return 'expected command to succeed'
  end
  # :nocov:
end
