require 'test_helper'

class Slayer::ServiceTest < Minitest::Test

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

  def test_pass_should_halt_execution
    assert RaisingService.early_pass.success?
  end

  def test_fail_should_halt_execution
    assert RaisingService.early_fail.failure?
  end

  def test_try_pass_should_prodce_value
    assert_equal 5, TryingService.try_and_get_5.value
  end

  def test_try_fail_should_produce_failure
    assert TryingService.try_and_get_0.failure?
  end

  def test_try_fail_can_override_status
    result = TryingService.try_and_get_0_with_status(status: :x)
    assert_equal :x, result.status
  end
end
