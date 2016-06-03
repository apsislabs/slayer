module Slayer
    class Service
        attr_accessor :called, :result

        # Internal: Service Class Methods
        class << self
            def call(*args, &block)
                # Run the Service and capture the result
                result = new.tap { |s|
                    s.run(*args, &block)
                }.result

                # Throw an exception if we don't return a result
                raise ServiceNotImplemented unless result.is_a? Result
                return result
            end
        end

        # Run the Service, rescue from Failures
        def run(*args, &block)
            begin
                run!(*args, &block)
            rescue ServiceFailure
            end
        end

        # Run the Service
        def run!(*args, &block)
            call(*args, &block).tap { |r|
                @called = r.success?
            }
        end

        # Fail the Service
        def fail! result:, message:
            @result = Result.new(result, message).tap(&:fail!)
        end

        # Pass the Service
        def pass! result:, message:
            @result = Result.new(result, message)
        end

        # Call the service
        def call
            raise NotImplementedError, "Services must define method `#call`."
        end

        # Do nothing
        def rollback
        end
    end
end
