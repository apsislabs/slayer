module Slayer
  # Hook adds the ability to wrap all calls to a class in a wrapper method. The
  # wrapper method is provided with a block that can be used to invoke the called
  # method.
  #
  # The methods #skip_hook and #only_hook can be used to control which methods are
  # and are not wrapped with the hook call.
  #
  # @example Including Hook on a class.
  #   class MyHookedClass
  #     include Hook
  #
  #     hook :say_hello_and_goodbye
  #
  #     def self.say_hello_and_goodbye
  #       puts "hello!"
  #
  #       yield # calls hooked method
  #
  #       puts "goodbye!"
  #     end
  #
  #     def self.say_something
  #       puts "something"
  #     end
  #   end
  #
  #   MyHookedClass.say_something
  #    # => "hello!"
  #    #    "something"
  #    #    "goodbye!"
  #
  # @example Skipping Hooks
  #
  # skip_hook :say_something, :do_something # the hook method will not be invoked for
  #                                         # these methods. They will be called directly.
  #
  # @example Only hooking
  #
  # only_hook :see_something, :hear_something # These are the only methods that will be
  #                                           # be hooked. All other methods will be
  #                                           # called directly.
  module Hook
    def self.included(klass)
      klass.extend ClassMethods
    end

    # Everything in Hook::ClassMethods automatically get extended onto the
    # class that includes Hook.
    module ClassMethods
      # Define the method that will be invoked whenever another method is invoked.
      # This should be a class method.
      def hook(hook_method)
        @__hook = hook_method
      end

      # Define the set of methods that should always be called directly, and should
      # never be hooked
      def skip_hook(*hook_skips)
        @__hook_skips = hook_skips
      end

      def singleton_skip_hook(*hook_skips)
        @__singleton_hook_skips = hook_skips
      end

      # If only_hook is called then only the methods provided will be hooked. All
      # other methods will be called directly.
      def only_hook(*hook_only)
        @__hook_only = hook_only
      end

      private

        def __hook
          @__hook ||= nil
        end

        def __hook_skips
          @__hook_skips ||= []
        end

        def __singleton_hook_skips
          @__singleton_hook_skips ||= []
        end

        def __hook_only
          @__hook_only ||= nil
        end

        def __current_methods
          @__current_methods ||= nil
        end

        def run_hook(name, instance, passed_block, &block)
          if __hook
            send(__hook, name, instance, passed_block, &block)
          else
            # rubocop:disable Performance/RedundantBlockCall
            block.call
            # rubocop:enable Performance/RedundantBlockCall
          end
        end

        def singleton_method_added(name)
          insert_hook_for(name,
                          define_method_fn: :define_singleton_method,
                          hook_target: self,
                          alias_target: singleton_class,
                          skip_methods: blacklist(__singleton_hook_skips))
        end

        def method_added(name)
          insert_hook_for(name,
                          define_method_fn: :define_method,
                          hook_target: self,
                          alias_target: self,
                          skip_methods: blacklist(__hook_skips))
        end

        def insert_hook_for(name, define_method_fn:, hook_target:, alias_target:, skip_methods: [])
          return if __current_methods && __current_methods.include?(name)

          with_hooks = :"__#{name}_with_hooks"
          without_hooks = :"__#{name}_without_hooks"

          return if __hook_only && !__hook_only.include?(name.to_sym)
          return if skip_methods.include? name.to_sym

          @__current_methods = [name, with_hooks, without_hooks]
          send(define_method_fn, with_hooks) do |*args, &block|
            hook_target.send(:run_hook, name, self, block) do
              send(without_hooks, *args)
            end
          end

          alias_target.send(:alias_method, without_hooks, name)
          alias_target.send(:alias_method, name, with_hooks)

          @__current_methods = nil
        end

        def blacklist(additional = [])
          list = Object.methods(false) + Object.private_methods(false)
          list += Slayer::Hook::ClassMethods.private_instance_methods(false)
          list += Slayer::Hook::ClassMethods.instance_methods(false)
          list += additional
          list << __hook if __hook

          list
        end
    end
  end
end
