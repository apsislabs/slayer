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

  def test_flunk_bang_should_halt_execution
    assert RaisingService.early_halting_flunk.failure?
    assert RaisingService.new.early_halting_flunk.failure?
  end

  def test_flunk_should_continue_execution
    assert_raises { RaisingService.early_flunk }
    assert_raises { RaisingService.new.early_flunk }
  end

  def test_try_pass_should_produce_value
    assert_equal 5, TryingService.try_and_get_5.value
    assert_equal 5, TryingService.new.try_and_get_5.value
  end

  def test_try_fail_should_produce_failure
    assert TryingService.try_and_get_0.failure?
    assert TryingService.new.try_and_get_0.failure?
  end

  def test_try_fail_can_override_status
    result = TryingService.try_and_get_0_with_status(status: :x)
    assert_equal :x, result.status

    result = TryingService.new.try_and_get_0_with_status(status: :x)
    assert_equal :x, result.status
  end

  def test_executes_block_passed_to_service
    assert_executes do
      MultiplyingService.mul(5, 5) do |r|
        assert r.is_a? Slayer::ResultMatcher
        r.all

        executes
      end
    end
  end

  def test_executes_pass_block_on_pass
    assert_executes do
      MultiplyingService.mul(5, 5) do |r|
        r.pass { executes }
        r.fail { flunk }
      end
    end
  end

  def test_executes_fail_block_on_fail
    assert_executes do
      MultiplyingService.mul(5, 0) do |r|
        r.pass { flunk }
        r.fail { executes }
      end
    end
  end

  def test_executes_ensure_block_on_pass
    assert_executes do
      MultiplyingService.mul(5, 5) do |r|
        r.pass
        r.fail   { flunk }
        r.ensure { executes }
      end
    end
  end

  def test_executes_ensure_block_on_fail
    assert_executes do
      MultiplyingService.mul(5, 0) do |r|
        r.pass   { flunk }
        r.fail
        r.ensure { executes }
      end
    end
  end

  def test_raises_if_all_defaults_not_handled
    assert_raises do
      MultiplyingService.mul(5, 0) do |r|
        r.pass {}
      end
    end
  end
end
