module Slayer
    class Service

        # Internal: Add Service functionality
        def self.included(base)
            base.class_eval do
                extend ClassMethods
                attr_accessor :called
            end
        end

        # Internal: Service Class Methods
        module ClassMethods
            # Public: Execute the service
            #
            # ==== Attributes
            #
            # - +*args+: Splat of your services arguments.
            #
            # ==== Examples
            #
            #   Service.call(foo: bar)
            #   # => <Slayer::Result>
            #
            # Returns a Result object.
            # Raises Slayer::ServiceFailure if the Service is failed
            # Raises Slayer::ServiceNotImplemented if the Service
            #   doesn't return a Result object
            def call!(*args)
                result = new.tap do |s|
                    s.run!(args)
                end

                # Throw an exception if we don't return a result
                raise ServiceNotImplemented unless result.is_a? Result
                return result
            end

            # Public: Execute the service
            #
            # ==== Attributes
            #
            # - +*args+: Splat of your services arguments.
            #
            # ==== Examples
            #
            #   Service.call(foo: bar)
            #   # => <Slayer::Result>
            #
            # Returns a Result object.
            # Raises Slayer::ServiceNotImplemented if the Service
            #   doesn't return a Result object
            def call!(*args)
                result = new.tap do |s|
                    s.run(args)
                end

                # Throw an exception if we don't return a result
                raise ServiceNotImplemented unless result.is_a? Result
                return result
            end
        end

        # Run the Service, rescue from Failures
        def run(*args)
            begin
                run!(args)
            rescue ServiceFailure
            end
        end

        # Run the Service
        def run!(*args)
            call(args)
            @called = true
        end

        # Fail the Service
        def fail! result:, message:
            return Result.new(result, message).fail!
        end

        # Pass the Service
        def pass! result:, message:
            return Result.new(result, message)
        end

        # Call the service
        def call
            raise NotImplementedError
        end

        # Do nothing
        def rollback
        end
    end
end
