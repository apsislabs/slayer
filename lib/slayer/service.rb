module Slayer
  class Service
    def self.before_each_method name
      @@allowed_services ||= nil

      # Is Allowed?

      if !@@allowed_services
        # If allowed services is not set, this is the _first_ call to a service object.
        # That's always allowed

        # YES
        puts "ALLOWED"
      else
        # Peek at the array of allowed services and make sure we're in it
        allowed = @@allowed_services.last
        if allowed && allowed.include?(self)
          # If we are in the set of allowed services, this has been explicitly approved.
          #YES
          puts "ALLOWED"
        else
          #NO
          raise ServiceDependencyError.new("Attempted to call #{self} from another #{Slayer::Service} which did not declare it as a dependency")
        end
      end

      @@allowed_services ||= []
      @@allowed_services << transitive_dependencies
    end

    def self.after_each_method name
      @@allowed_services.pop
      p [:after_method, name, self]

      if @@allowed_services.empty?
        @@allowed_services = nil
      end

      p @@allowed_services
    end

    def self.singleton_method_added name
      return if self == Slayer::Service
      return if @__last_methods_added && @__last_methods_added.include?(name)

      p [:singleton_method_added, name, self]

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

      # p self
      # p methods - Object.methods

      singleton_class.send(:alias_method, without, name)

      # p methods - Object.methods

      singleton_class.send(:alias_method, name, with) # alias_method name, with

      # p methods - Object.methods

      @__last_methods_added = nil
    end

    def self.dependencies(*deps)
      raise ServiceDependencyError.new("There were multiple dependencies calls of #{self}") if @dependencies

      deps.each{ |dep|
        raise ServiceDependencyError.new("The object #{dep} passed to dependencies service was not a class")       unless dep.is_a?(Class)
        raise ServiceDependencyError.new("The object #{dep} passed to dependencies was not a subclass of #{self}") unless dep < Slayer::Service
      }

      raise ServiceDependencyError.new("There were duplicate dependencies in #{self}") unless deps.uniq.length == deps.length

      @dependencies = deps
    end

    def self.transitive_dependencies(dependency_hash = {}, visited = [])
      return @transitive_dependencies if @transitive_dependencies

      @dependencies ||= []

      # If we've already visited ourself, bail out. This is necessary to halt
      # execution for a circular chain of dependencies. #halting-problem-solved
      if visited.include?(self)
        return dependency_hash[self]
      end

      visited << self
      dependency_hash[self] ||= []

      # Add each of our dependencies (and it's transitive dependency chain) to our
      # own dependencies.

      @dependencies.each { |dep|
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
  end
end
