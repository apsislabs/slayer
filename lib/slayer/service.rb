module Slayer
  class Service

    def self.dependencies(*deps)
      raise ServiceDependencyError.new("There were multiple dependencies calls of #{self}") if @deps

      deps.each{ |dep|
        raise ServiceDependencyError.new("The object #{dep} passed to dependencies service was not a class")       unless dep.is_a?(Class)
        raise ServiceDependencyError.new("The object #{dep} passed to dependencies was not a subclass of #{self}") unless dep < Slayer::Service
      }

      raise ServiceDependencyError.new("There were duplicate dependencies in #{self}") unless deps.uniq.length == deps.length

      @deps = deps

      # Calculate the transitive dependencies and throw an error if there are circular dependencies
      transitive_dependencies
    end

    private

    def self.transitive_dependencies(dependency_hash = {}, visited = [])
      return @transitive_dependencies if @transitive_dependencies

      @deps ||= []

      # If we've already visited ourself, bail out. This is necessary to halt
      # execution for a circular chain of dependencies. #halting-problem-solved
      if visited.include?(self)
        return dependency_hash[self]
      end

      visited << self
      dependency_hash[self] ||= []

      # Add each of our dependencies (and it's transitive dependency chain) to our
      # own dependencies.

      @deps.each { |dep|
        dependency_hash[self] << dep

        if !visited.include?(dep)
          child_transitive_dependencies = dep.transitive_dependencies(dependency_hash, visited)
          dependency_hash[self].concat(child_transitive_dependencies)
        end

        dependency_hash[self].uniq
      }

      # NO CIRCULAR DEPENDENCIES!
      if dependency_hash[self].include? self
        raise ServiceDependencyError.new("#{self} had a circular dependency")
      end

      # Store these now, so next time we can short-circuit.
      @transitive_dependencies = dependency_hash[self]

      return @transitive_dependencies
    end

    def self.before_each_method name
      @deps ||= []
      @@allowed_services ||= nil

      # Confirm that this method call is allowed
      raise_if_not_allowed

      @@allowed_services ||= []
      @@allowed_services << @deps
    end

    def self.raise_if_not_allowed
      if @@allowed_services
        allowed = @@allowed_services.last
        if !allowed || !allowed.include?(self)
          raise ServiceDependencyError.new("Attempted to call #{self} from another #{Slayer::Service} which did not declare it as a dependency")
        end
      end
    end

    def self.after_each_method name
      @@allowed_services.pop
      @@allowed_services = nil if @@allowed_services.empty?
    end

    def self.singleton_method_added name
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

    def self.method_added name
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

    def self.deps
      @deps
    end
  end
end
