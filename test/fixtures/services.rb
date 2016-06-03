# A service that passes when given the string "foo"
# and fails if given anything else.
class FooService < Slayer::Service
    def call(foo:)
      if foo == "foo"
        pass! result: foo, message: "Passing FooService"
      else
        fail! result: foo, message: "Failing FooService"
      end
    end
end

# A placeholder service that always passes with returned result
# as the argument passed into it.
class BarService < Slayer::Service
    def call(bar:)
        pass! result: bar, message: "Passing BarService"
    end
end

# A service which does not properly implement the service interface
class NotImplementedService < Slayer::Service
  def call
    return true
  end
end

# An invalid service which does not define the `call` method
class InvalidService < Slayer::Service
end
