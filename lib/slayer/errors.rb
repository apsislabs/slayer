module Slayer
    class ServiceFailure < StandardError
        attr_reader :result

        def initialize(result)
            @result = result
            super
        end
    end

    class ServiceNotImplemented < StandardError
        def initialize(message = nil)
            message ||= %q(
                Service implementation must call `fail!` or `pass!`,
                or return a <Slayer::Result> object
            )

            super message
        end
    end
end
