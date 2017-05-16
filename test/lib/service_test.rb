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
end
