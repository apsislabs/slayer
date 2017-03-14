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
end
