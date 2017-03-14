module Slayer
  class Service
    include Hook

    def self.inherited(klass)
      klass.include Hook
      klass.hook :result_machinery
    end

    hook :result_machinery

    def self.result_machinery(name)
      puts "PRE result machinery (#{name})"

      yield

      puts "POST result machinery (#{name})"
    end
  end # class Service

  # class Other < Service
  #   def do_other_thing
  #     puts "other"
  #   end
  #
  #   def self.self_other_thing
  #     puts "self other"
  #   end
  # end
  #
  # class EvenFurther < Other
  #   def do_further_thing
  #     puts "further"
  #   end
  #
  #   def self.self_further_thing
  #     puts "self further"
  #   end
  # end
end # module Slayer
