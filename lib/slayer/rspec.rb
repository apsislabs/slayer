require 'rspec/expectations'
# rubocop:disable Metrics/BlockLength
RSpec::Matchers.define :be_success_result do
  match do |result|
    status_matches = @status.nil? || @status == result.status
    message_matches = @message.nil? || @message == result.message
    value_matches = @value.nil? || @value == result.value

    result.ok? && status_matches && message_matches && value_matches
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

  chain :with do |args|
    @status = args[:status] if args.key? :status
    @message = args[:message] if args.key? :message
    @value = args[:value] if args.key? :value
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
    status_matches = @status.nil? || @status == result.status
    message_matches = @message.nil? || @message == result.message
    value_matches = @value.nil? || @value == result.value

    result.err? && status_matches && message_matches && value_matches
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

  chain :with do |args|
    @status = args[:status] if args.key? :status
    @message = args[:message] if args.key? :message
    @value = args[:value] if args.key? :value
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
# rubocop:enable Metrics/BlockLength
