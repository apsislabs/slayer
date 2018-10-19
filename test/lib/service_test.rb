require 'test_helper'

class Slayer::ServiceTest < Minitest::Test

  # Class Tests
  # ---------------------------------------------

  def test_default_does_not_wrap
    refute_executes do
      result = BoringService.new.add(2, 2) do
        executes
      end
      assert result.is_a? Numeric
      assert_equal result, 4
    end
  end

  def test_default_does_not_wrap_class_methods
    refute_executes do
      result = BoringService.add(2, 2) do
        executes
      end
      assert result.is_a? Numeric
      assert_equal result, 4
    end
  end

  def test_instance_pass_should_be_success
    assert MultiplyingService.new.inst_mul(5, 5).success?
  end

  def test_instance_fail_should_be_failure
    assert MultiplyingService.new.inst_mul(0, 5).failure?
  end

  def test_static_pass_should_be_success
    assert MultiplyingService.mul(5, 5).success?
  end

  def test_static_fail_should_be_failure
    assert MultiplyingService.mul(0, 5).failure?
  end

  def test_flunk_bang_should_halt_execution
    assert RaisingService.early_halting_flunk.failure?
    assert RaisingService.new.early_halting_flunk.failure?
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
