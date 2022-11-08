# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity
class YieldResult < RSpec::Matchers::BuiltIn::YieldControl
  def with_pass
    @pass_expected = true
    self
  end

  def with_fail
    @fail_expected = true
    self
  end

  def with_ensure
    @ensure_expected = true
    self
  end

  def matches?(block)
    is_matcher = false

    @probe = RSpec::Matchers::BuiltIn::YieldProbe.probe(block) do |r|
      is_matcher = r.is_a? Slayer::ResultMatcher

      r.pass { @passed = true }
      r.fail { @failed = true }
      r.ensure { @ensured = true }

      r.all
    end

    return false unless @probe.has_block?
    return false unless is_matcher

    return false if @pass_expected && (!@passed || @failed)
    return false if @fail_expected && (!@failed || @passed)
    return false if @ensure_expected && !@ensured

    if @expectation_type
      @probe.num_yields.__send__(@expectation_type, @expected_yields_count)
    else
      @probe.yielded_once?(:yield_control)
    end
  end

  def failure_message
    'expected given block to handle results' + failure_reason
  end

  def failure_message_when_negated
    'expected given block not to handle results' + failure_reason
  end
end

module RSpec::Matchers
  def yield_result
    YieldResult.new
  end
end
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity
