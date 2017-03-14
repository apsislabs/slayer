require 'test_helper'

class Slayer::ServiceTest < Minitest::Test
  def test_hooks_run
    a = Slayer::Service.new

    puts "---------------------------------------------------------------------"
    a.do_instance_thing
    puts "---------------------------------------------------------------------"
    Slayer::Service.do_self_thing
    puts "---------------------------------------------------------------------"
  end

  def test_child_hooks_run
    klass = Class.new(Slayer::Service) { def child_instance_thing; puts "child instance"; end; def self.child_self_thing; puts "child self"; end }

    k = klass.new

    puts "---------------------------------------------------------------------"
    k.child_instance_thing
    puts "---------------------------------------------------------------------"
    k.do_instance_thing

    puts "---------------------------------------------------------------------"
    klass.child_self_thing
    puts "---------------------------------------------------------------------"
    klass.do_self_thing
    puts "---------------------------------------------------------------------"
  end
  def test_should_have_tests; skip; end
end
