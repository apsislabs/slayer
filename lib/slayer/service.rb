module Slayer
  class Service
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
