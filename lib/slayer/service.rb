module Slayer
  # Slayer Services are objects that should implement re-usable pieces of
  # application logic or common tasks. To prevent circular dependencies Services
  # are required to declare which other Service classes they depend on. If a
  # circular dependency is detected an error is raised.
  #
  # In order to enforce the lack of circular dependencies, Service objects can
  # only call other Services that are declared in their dependencies.
  class Service
    # List the other Service class that this service class depends on. Only
    # dependencies that are included in this call my be invoked from class
    # or instances methods of this service class.
    #
    # If no dependencies are provided, no other Service classes may be used by
    # this Service class.
    #
    # @param deps [Array<Class>] An array of the other Slayer::Service classes that are used as dependencies
    #
    # @example Service calls with dependency declared
    #   class StripeService < Slayer::Service
    #     dependencies NetworkService
    #
    #     def self.pay()
    #       ...
    #       NetworkService.post(url: "stripe.com", body: my_payload) # OK
    #       ...
    #     end
    #   end
    #
    # @example Service calls without a dependency declared
    #   class JiraApiService < Slayer::Service
    #
    #     def self.create_issue()
    #       ...
    #       NetworkService.post(url: "stripe.com", body: my_payload) # Raises Slayer::ServiceDependencyError
    #       ...
    #     end
    #   end
    #
    # @return [Array<Class>] The transitive closure of dependencies for this object.
    def self.dependencies(*deps)
      raise(ServiceDependencyError, "There were multiple dependencies calls of #{self}") if @deps

      deps.each { |dep|
        unless dep.is_a?(Class)
          raise(ServiceDependencyError, "The object #{dep} passed to dependencies service was not a class")
        end

        unless dep < Slayer::Service
          raise(ServiceDependencyError, "The object #{dep} passed to dependencies was not a subclass of #{self}")
        end
      }

      unless deps.uniq.length == deps.length
        raise(ServiceDependencyError, "There were duplicate dependencies in #{self}")
      end

      @deps = deps

      # Calculate the transitive dependencies and raise an error if there are circular dependencies
      transitive_dependencies
    end

    private

    class << self
      attr_reader :deps

      def transitive_dependencies(dependency_hash = {}, visited = [])
        return @transitive_dependencies if @transitive_dependencies

        @deps ||= []

        # If we've already visited ourself, bail out. This is necessary to halt
        # execution for a circular chain of dependencies. #halting-problem-solved
        return dependency_hash[self] if visited.include?(self)

        visited << self
        dependency_hash[self] ||= []

        # Add each of our dependencies (and it's transitive dependency chain) to our
        # own dependencies.

        @deps.each { |dep|
          dependency_hash[self] << dep

          unless visited.include?(dep)
            child_transitive_dependencies = dep.transitive_dependencies(dependency_hash, visited)
            dependency_hash[self].concat(child_transitive_dependencies)
          end

          dependency_hash[self].uniq
        }

        # NO CIRCULAR DEPENDENCIES!
        if dependency_hash[self].include? self
          raise(ServiceDependencyError, "#{self} had a circular dependency")
        end

        # Store these now, so next time we can short-circuit.
        @transitive_dependencies = dependency_hash[self]

        return @transitive_dependencies
      end

      def before_each_method(name)
        @deps ||= []
        @@allowed_services ||= nil

        # Confirm that this method call is allowed
        raise_if_not_allowed

        @@allowed_services ||= []
        @@allowed_services << @deps
      end

      def raise_if_not_allowed
        if @@allowed_services
          allowed = @@allowed_services.last
          if !allowed || !allowed.include?(self)
            raise(ServiceDependencyError, "Attempted to call #{self} from another #{Slayer::Service}"\
                                          ' which did not declare it as a dependency')
          end
        end
      end

      def after_each_method(name)
        @@allowed_services.pop
        @@allowed_services = nil if @@allowed_services.empty?
      end

      def singleton_method_added(name)
        return if self == Slayer::Service
        return if @__last_methods_added && @__last_methods_added.include?(name)

        with = :"#{name}_with_before_each_method"
        without = :"#{name}_without_before_each_method"

        @__last_methods_added = [name, with, without]
        define_singleton_method with do |*args, &block|
          before_each_method name
          begin
            send without, *args, &block
          rescue
            raise
          ensure
            after_each_method name
          end
        end

        singleton_class.send(:alias_method, without, name)
        singleton_class.send(:alias_method, name, with)

        @__last_methods_added = nil
      end

      def method_added(name)
        return if self == Slayer::Service
        return if @__last_methods_added && @__last_methods_added.include?(name)

        with = :"#{name}_with_before_each_method"
        without = :"#{name}_without_before_each_method"

        @__last_methods_added = [name, with, without]
        define_method with do |*args, &block|
          self.class.before_each_method name
          begin
            send without, *args, &block
          rescue
            raise
          ensure
            self.class.after_each_method name
          end
        end

        alias_method without, name
        alias_method name, with

        @__last_methods_added = nil
      end
    end # << self
  end # class Service
end # module Slayer
