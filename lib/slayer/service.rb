module Slayer
  class Service
    include Hook

    puts "SELF WITH HOOKS: #{self.inspect}"
    puts "SELF WITH HOOKS: #{self.methods.sort}"

    hook :result_machinery

    def do_instance_thing
      puts "instance"
    end

    def self.do_self_thing
      puts "self"
    end

    def self.result_machinery
      puts "PRE result machinery"

      yield

      puts "POST result machinery"
    end
  end # class Service
end # module Slayer
