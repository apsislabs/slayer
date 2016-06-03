module Slayer
    class Organizer
        def self.included(base)
            base.class_eval do
                include Service

                extend ClassMethods
                include InstanceMethods
            end
        end

        module ClassMethods
            def organize(*services)
                @services = services.flatten
            end

            def services
                @services ||= []
            end

            # TODO: We should convert service_class_results to a call to
            # `service_results(service)`
            def method_missing(method_sym, *arguments, &block)
                if method_sym.to_s =~ /^(.*)_results$/
                    # Convert $1 to Class
                    # pass to `service_results($1)`
                else
                    super
                end
            end
        end

        module InstanceMethods
            attr_accessor :results
            attr_accessor :called_services
            attr_accessor :organizer_params

            def run!(*args)
                @organizer_params = args

                # Attempt to run each Service, if any fail,
                # call rollback on all those already run in
                # reverse order.
                begin
                    self.class.services.each do |service|
                        service_sym  = service_to_sym(service)
                        service_args = service_to_args(service)

                        # Run the service then add it to called_services
                        @results[service_sym] = service.call!(service_args)
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
end
