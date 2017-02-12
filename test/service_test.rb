require 'test_helper'
require 'set'

class Slayer::ServiceTest < Minitest::Test
  # Dependencies
  def test_empty_dependencies_doesnt_raise
    Class.new(Slayer::Service) { dependencies() }
    Class.new(Slayer::Service) { }
  end

  def test_dependencies_with_no_class_raises
    assert_raises Slayer::ServiceDependencyError do
      Class.new(Slayer::Service) { dependencies(:b_service) }
    end
  end

  def test_dependencies_with_non_service_class_raises
    assert_raises Slayer::ServiceDependencyError do
      Class.new(Slayer::Service) { dependencies(Slayer::Command) }
    end
  end

  def test_multiple_dependencies_raises
    assert_raises Slayer::ServiceDependencyError do
      service = Class.new(Slayer::Service)
      Class.new(Slayer::Service) { dependencies(service); dependencies(service); }
    end

    assert_raises Slayer::ServiceDependencyError do
      Class.new(Slayer::Service) { dependencies; dependencies;}
    end

    assert_raises Slayer::ServiceDependencyError do
      service = Class.new(Slayer::Service)
      Class.new(Slayer::Service) { dependencies; dependencies(service); }
    end
  end

  def test_duplicate_dependencies_raises
    assert_raises Slayer::ServiceDependencyError do
      service = Class.new(Slayer::Service)
      Class.new(Slayer::Service) { dependencies(service, service) }
    end
  end

  # Transitive and Circular Dependencies
  def test_circular_dependencies_raises
    s(:FirstService) {
      s(:SecondService) {
        SecondService.dependencies FirstService
        FirstService.dependencies  SecondService

        assert_raises Slayer::ServiceDependencyError do
          FirstService.transitive_dependencies
        end
      }
    }
  end

  def test_transitive_dependency_chain
    assert_array_contents_equal CService.transitive_dependencies, [BService, AService]
  end

  def test_service_can_be_called_from_anywhere
    assert_equal AService.return_5, 5, "AService should directly produce the result of 5"
  end

  def test_service_can_be_called_if_listed_in_dependencies
    assert_equal BService.return_10, 10, "BService should've produced the result of 10 using AService"
  end

  def test_raises_exception_if_service_calls_another_service_not_listed_in_dependencies
    s(:NoDependencyListedService,
      Proc.new { def self.do_no_dependency_thing; AService.return_5 * 3; end }) {

      assert_raises Slayer::ServiceDependencyError, "Should not be able to call AService if it's not listed as a dependency" do
        NoDependencyListedService.do_no_dependency_thing
      end
    }
  end

  private
  def s(name, service_block = nil, &block)
    create_service(name: name, &service_block)

    yield

    cleanup_service(name: name)
  end

  def create_service(name: nil, &block)
    return Class.new(Slayer::Service, &block).tap{ |service|
      Object.const_set(name, service) if name
    }
  end

  def cleanup_service(name: nil)
    Object.send(:remove_const, name)
  end

  def assert_array_contents_equal(actual, expected, message = nil)
    actual_set   = Set.new actual
    expected_set = Set.new expected

    assert_equal actual_set, expected_set, message
  end
end
