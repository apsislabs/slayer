# A service that passes when given the string "foo"
# and fails if given anything else.
class FooCommand < Slayer::Command
  def call foo:
    if foo == "foo"
      pass! result: foo, message: "Passing FooCommand"
    else
      fail! result: foo, message: "Failing FooCommand"
    end
  end
end

# A placeholder service that always passes with returned result
# as the argument passed into it.
class BarCommand < Slayer::Command
  def call bar:
    pass! result: bar, message: "Passing BarCommand"
  end
end

# A service which does not properly implement the service interface
class NotImplementedCommand < Slayer::Command
  def call
    return true
  end
end

# An invalid service which does not define the `call` method
class InvalidCommand < Slayer::Command
end
