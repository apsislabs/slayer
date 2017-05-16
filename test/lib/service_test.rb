require 'test_helper'

class Slayer::ServiceTest < Minitest::Test

  # Class Tests
  # ---------------------------------------------

  def test_instantiates_and_calls_expected_methods
    ScopedService.expects(:call).once
    ScopedService.call
  end

  def test_wraps_correct_methods
    # Instance Methods accessible
    service_instance = ScopedService.new
    assert service_instance.respond_to? :call
    assert service_instance.respond_to? :not_call
    refute service_instance.respond_to? :private_call

    # Class methods accessible
    assert ScopedService.respond_to? :call
    assert ScopedService.respond_to? :not_call
    refute ScopedService.respond_to? :private_call
  end

  # Instance Tests
  # ---------------------------------------------

  def test_executes_block_passed_to_service
    assert_executes do
      TestService.pass_5 do |r|
        assert r.is_a? Slayer::ResultMatcher
        r.all
        executes
      end
    end
  end

  def test_executes_pass_block_on_pass
    assert_executes do
      TestService.pass_5 do |r|
        r.pass { executes }
        r.fail { flunk }
      end
    end
  end

  def test_executes_fail_block_on_fail
    assert_executes do
      TestService.flunk_10 do |r|
        r.pass { flunk }
        r.fail { executes }
      end
    end
  end

  def test_result_has_expected_properties_on_pass
    result = TestService.pass_5
    assert_equal result.value, 5
    assert result.success?
  end

  def test_result_has_expected_properties_on_flunk
    result = TestService.flunk_10
    assert_equal result.value, 10
    refute result.success?
  end
end
