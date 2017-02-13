require 'test_helper'
require 'set'

class Slayer::ServiceTest < Minitest::Test
  # Dependencies
  def test_empty_dependencies_doesnt_raise
    Class.new(Slayer::Service) { dependencies() }
    Class.new(Slayer::Service) { }
  end

  def test_raises_error_for_invalid_dependencies
    assert_raises Slayer::ServiceDependencyError do
      Class.new(Slayer::Service) { dependencies(:b_service) }
    end
  end

  def test_raises_error_for_non_service_class_dependencies
    assert_raises Slayer::ServiceDependencyError do
      Class.new(Slayer::Service) { dependencies(Slayer::Command) }
    end
  end

  def test_raises_error_for_multiple_dependencies
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

  def test_raises_error_for_duplicate_dependencies
    assert_raises Slayer::ServiceDependencyError do
      service = Class.new(Slayer::Service)
      Class.new(Slayer::Service) { dependencies(service, service) }
    end
  end

  # Transitive and Circular Dependencies
  def test_raises_error_for_circular_dependencies
    s(:FirstService) {
      s(:SecondService) {
        SecondService.dependencies FirstService

        assert_raises Slayer::ServiceDependencyError do
          FirstService.dependencies  SecondService
        end
      }
    }
  end

  def test_transitive_dependency_chain
    assert_array_contents_equal CService.transitive_dependencies, [BService, AService]
  end

  # Dependency Enforcements
  def test_instance_calls_allowed_from_non_service_class
    assert_equal AService.new.return_3, 3, 'AService instance should directly produce the result of 3'
  end

  def test_instance_calls_allowed_when_in_dependencies
    assert_equal BService.new.return_6, 6,   'BService instance should\'ve produced the '\
                                             'result of 6 using AService instance'
    assert_equal CService.return_8, 8,       'BService instance should\'ve produced the result of '\
                                             '15 using AService'
    assert_equal BService.new.return_15, 15, 'BService instance should\'ve produced the result of '\
                                             '15 using AService'
  end

  def test_raises_error_for_disallowed_call_from_instance
    s(:NoDependencyListedService,
      Proc.new { def do_no_dependency_thing; AService.return_5 * 3; end }) {

      assert_raises Slayer::ServiceDependencyError,
                    'Instance should not be able to call AService if it\'s not listed as a dependency' do
        NoDependencyListedService.new.do_no_dependency_thing
      end
    }

    s(:NoDependencyListedService,
      Proc.new { def do_no_dependency_thing; AService.new.return_3 * 3; end }) {

      assert_raises Slayer::ServiceDependencyError,
                    'Instance should not be able to call AService instance if it\'s not listed as a dependency' do
        NoDependencyListedService.new.do_no_dependency_thing
      end
    }
  end

  def test_calls_allowed_from_non_service_class
    assert_equal AService.return_5, 5, 'AService should directly produce the result of 5'
  end

  def test_calls_allowed_when_in_dependencies
    assert_equal BService.return_10, 10, 'BService should\'ve produced the result of 10 using AService'
  end

  def test_raises_error_for_disallowed_call
    s(:NoDependencyListedService,
      Proc.new { def self.do_no_dependency_thing; AService.return_5 * 3; end }) {

      assert_raises Slayer::ServiceDependencyError,
                    'Should not be able to call AService if it\'s not listed as a dependency' do
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
