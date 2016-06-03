module Slayer
    class Composer < Service
        attr_accessor :called
        attr_accessor :results
        attr_accessor :called_services
        attr_accessor :composer_params

        class << self
            def compose(*services)
                @services = services.flatten
            end

            def services
                @services ||= []
            end
        end

        # Locate Results from Magic Methods
        def method_missing(method_sym, *arguments, &block)
            if method_sym.to_s =~ /^(.*)_results$/
                results = @results[$1.to_sym]
                return results unless results.nil?
            end

            super
        end

        def run!(**args, &block)
            @composer_params = args
            @called_services = []
            @results = {}

            # Attempt to run each Service, if any fail,
            # call rollback on all those already run in
            # reverse order.
            begin
                self.class.services.each do |service|
                    service_sym  = service_to_sym(service)
                    service_args = service_to_args(service)

                    # Run the service then add it to called_services
                    @results[service_sym] = service.new.run!(service_args)
                    @called_services << service
                end
            rescue ServiceFailure
                @called_services.reverse_each do |service|
                    service_args   = service_to_args(service)
                    service_result = service_results(service)

                    # Pass the original args and result object
                    service.rollback(service_args, service_result)
                end

                raise
            end

            call
            @called = true
        end

        private

            # Convert a Service to an underscored symbol
            def service_to_sym(service)
                service.name.underscore.to_sym
            end

            # Convert a Service to a call to an args method
            def service_to_args(service)
                service_sym = service_to_sym(service)
                self.method("#{service_sym}_args").call
            end

            # Convert a Service to its result object
            def service_results(service)
                service_sym = service_to_sym(service)
                return @results[service_sym]
            end
    end
end
