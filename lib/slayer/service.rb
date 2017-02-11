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
      # return @transitive_dependencies if @transitive_dependencies

      puts "VISITING #{self}"
      puts "\tDEPENDENCIES: #{@dependencies}"

      if visited.include?(self)
        return dependency_hash[self]
      end

      visited << self

      dependency_hash[self] ||= []

      @dependencies.each { |dep|
        # visit dependency
        dependency_hash[self] << dep

        if !visited.include?(dep)
          child_transitive_dependencies = dep.transitive_dependencies(dependency_hash, visited)
          dependency_hash[self].concat(child_transitive_dependencies)
        end

        puts "\tChild T DEP: #{child_transitive_dependencies}"

        dependency_hash[self].uniq
      }

      puts "\tSelf Dep Hash: #{dependency_hash[self]}"

      if dependency_hash[self].include? self
        puts "Raising Service Dependency Error"
        byebug
        raise ServiceDependencyError.new("#{self} had a circular dependency")
      end

      puts "FINISHED VISITING #{self}"

      @transitive_dependencies = dependency_hash[self]

      return @transitive_dependencies
    end

    private

    def actual_transitive_dependencies()
    end
  end
end
