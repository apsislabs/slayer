module Slayer
    # Dependable objects are objects that may only call other Dependable objects if
  # they declare ane explicit dependency. The main aim is to prevent circular dependencies
  # in various layers of an application. If a circular dependency is detected, an
  # error is raised.
  #
  # @example Including Dependable on a base class
  #   class Service
  #     include Dependable
  #     ...
  #   end
  #
  #   class NetworkService < Service
  #     ...
  #   end
  #
  #   class StripeService < Service
  #     dependencies NetworkService
  #     ...
  #   end
  #
  module Hook
    def self.included(klass)
      klass.extend ClassMethods
    end

    # Everything in Dependable::ClassMethods automatically get extended onto the
    # class that includes Dependable.
    module ClassMethods

      def hook(hook_method)
        @__hook = hook_method
      end

      def skip_hooking(*hook_skips)
        @__hook_skips = hook_skips
      end

      def __hook
        @__hook ||= nil
      end

      def __hook_skips
        @__hook_skips ||= []
      end

      def run_hook(name, passed_block, &block)
        if __hook
          send(__hook, name, passed_block, &block)
        else
          yield
        end
      end

      # Method hook infrastructure
      def singleton_method_added(name)
        insert_hook_for(name,
                         define_method_fn: :define_singleton_method,
                         hook_target: self,
                         alias_target: singleton_class)
      end

      def method_added(name)
        insert_hook_for(name,
                         define_method_fn: :define_method,
                         hook_target: self,
                         alias_target: self)
      end

      def insert_hook_for(name, define_method_fn:, hook_target:, alias_target:)
        return if @__current_methods && @__current_methods.include?(name)

        with_hooks = :"__#{name}_with_hooks"
        without_hooks = :"__#{name}_without_hooks"

        blacklist = [:insert_hook_for, :method_added, :singleton_method_added,
          :run_hook, :before_hooks, :__before_hooks, :after_hooks, :__after_hooks]
        blacklist << __hook if __hook
        blacklist += __hook_skips
        return if blacklist.include? name.to_sym

        @__current_methods = [name, with_hooks, without_hooks]
        send(define_method_fn, with_hooks) do |*args, &block|

          hook_target.run_hook(name, block) do
            send(without_hooks, *args)
          end
        end

        alias_target.send(:alias_method, without_hooks, name)
        alias_target.send(:alias_method, name, with_hooks)

        @__current_methods = nil
      end
    end
  end
end
