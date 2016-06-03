# A simple composer which composes the FooService and BarService
class FooBarComposer < Slayer::Composer
    compose FooService, BarService

    def call
        pass! result: @results,  message: "Yay!"
    end

    def foo_service_args
        return { foo: @composer_params[:foo] }
    end

    def bar_service_args
        return { bar: foo_service_results.message }
    end
end
