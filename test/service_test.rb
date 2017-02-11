require 'test_helper'

class Slayer::ServiceTest < Minitest::Test
  # class AService < Slayer::Service; end
  # class BService < Slayer::Service; dependencies AService; end
  # class CService < Slayer::Service; dependencies :BService; end

  # Dependencies
  def test_empty_dependencies_doesnt_raise
    a_service = Class.new(Slayer::Service) { dependencies() }
  end

  def test_dependencies_with_no_class_raises
    assert_raises Slayer::ServiceDependencyError do
      a_service = Class.new(Slayer::Service) { dependencies(:b_service) }
    end
  end

  def test_dependencies_with_non_service_class_raises
    assert_raises Slayer::ServiceDependencyError do
      a_service = Class.new(Slayer::Service) { dependencies(Slayer::Command) }
    end
  end

  def test_multiple_dependencies_raises
    assert_raises Slayer::ServiceDependencyError do
      a_service = Class.new(Slayer::Service)
      b_service = Class.new(Slayer::Service) { dependencies(a_service); dependencies(a_service); }
    end

    assert_raises Slayer::ServiceDependencyError do
      a_service = Class.new(Slayer::Service) { dependencies; dependencies;}
    end

    assert_raises Slayer::ServiceDependencyError do
      a_service = Class.new(Slayer::Service)
      b_service = Class.new(Slayer::Service) { dependencies; dependencies(a_service); }
    end
  end

  def test_duplicate_dependencies_raises
    assert_raises Slayer::ServiceDependencyError do
      a_service = Class.new(Slayer::Service)
      b_service = Class.new(Slayer::Service) { dependencies(a_service, a_service) }
    end
  end

  # Transitive and Circular Dependencies
  def test_circular_dependencies_raises
    assert_raises Slayer::ServiceDependencyError do
      a_service = Class.new(Slayer::Service)
      b_service = Class.new(Slayer::Service) { dependencies(a_service) }

      a_service.dependencies(b_service)

      assert_raises Slayer::ServiceDependencyError do
        a_service.transitive_dependencies
      end
    end
  end

  private
  def assert_array_contents_equal(actual, expected, message = nil)
    assert_equal actual.sort, expected.sort, message
  end
end
