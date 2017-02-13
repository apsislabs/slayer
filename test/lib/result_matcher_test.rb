require 'test_helper'

class Slayer::ResultMatcherTest < Minitest::Test

    def test_handled_defaults_false_for_no_default_pass
        r = matcher_with_pass_result
        r.fail
        refute r.handled_defaults?

        r = matcher_with_pass_result
        r.all(:ok)
        r.fail
        refute r.handled_defaults?

        r = matcher_with_pass_result
        r.pass(:ok, :awesome)
        r.fail
        refute r.handled_defaults?
    end

    def test_handled_defaults_false_for_no_default_fail
        r = matcher_with_pass_result
        r.pass
        refute r.handled_defaults?

        r = matcher_with_pass_result
        r.all(:ok)
        r.pass
        refute r.handled_defaults?

        r = matcher_with_pass_result
        r.pass
        r.fail(:bad, :not_found)
        refute r.handled_defaults?

        r = matcher_with_pass_result
        r.pass
        r.fail(:bad)
        r.fail(:not_found)
        refute r.handled_defaults?
    end

    def test_handled_defaults_true
        r = matcher_with_pass_result
        r.pass
        r.fail
        assert r.handled_defaults?

        r = matcher_with_pass_result
        r.pass(:default)
        r.fail
        assert r.handled_defaults?

        r = matcher_with_pass_result
        r.pass(:ok, :default)
        r.fail
        assert r.handled_defaults?

        r = matcher_with_pass_result
        r.pass(:ok)
        r.pass
        r.fail(:ok)
        r.fail(:default)
        assert r.handled_defaults?
    end

    def test_handled_defaults_true_for_all
        r = matcher_with_pass_result
        r.all
        assert r.handled_defaults?

        r = matcher_with_pass_result
        r.all(:ok, :default)
        assert r.handled_defaults?
    end

    def test_executes_matching_pass_block
        assert_executes do
            r = matcher_with_pass_result(status: :ok)
            r.pass(:ok) { executes }
            r.pass      { flunk }
            r.execute_matching_block
        end

        assert_executes do
            r = matcher_with_pass_result(status: :ok)
            r.pass(:ok, :default) { executes }
            r.fail(:ok)           { flunk }
            r.execute_matching_block
        end
    end

    def test_executes_default_pass_block
        assert_executes do
            r = matcher_with_pass_result(status: :ok)
            r.pass(:other) { flunk }
            r.pass         { executes }
            r.execute_matching_block
        end

        assert_executes do
            r = matcher_with_pass_result(status: :ok)
            r.pass(:other, :default) { executes }
            r.execute_matching_block
        end
    end

    def test_executes_matching_fail_block
        assert_executes do
            r = matcher_with_fail_result(status: :ok)
            r.pass(:ok) { flunk }
            r.fail(:ok) { executes }
            r.fail      { flunk }
            r.execute_matching_block
        end

        assert_executes do
            r = matcher_with_fail_result(status: :ok)
            r.fail(:ok, :default) { executes }
            r.pass(:ok)           { flunk }
            r.execute_matching_block
        end
    end

    def test_executes_default_fail_block
        assert_executes do
            r = matcher_with_fail_result(status: :ok)
            r.fail(:other) { flunk }
            r.fail         { executes }
            r.execute_matching_block
        end

        assert_executes do
            r = matcher_with_fail_result(status: :ok)
            r.fail(:other, :default) { executes }
            r.execute_matching_block
        end
    end

    def test_executes_matching_all_block
        assert_executes do
            r = matcher_with_pass_result(status: :ok)
            r.pass      { flunk }
            r.all(:ok) { executes }
            r.fail      { flunk }
            r.execute_matching_block
        end

        assert_executes do
            r = matcher_with_fail_result(status: :ok)
            r.pass      { flunk }
            r.all(:ok) { executes }
            r.fail      { flunk }
            r.execute_matching_block
        end
    end

    def test_executes_default_all_block
        assert_executes do
            r = matcher_with_fail_result(status: :ok)
            r.pass(:ok)   { flunk }
            r.all         { executes }
            r.execute_matching_block
        end

        assert_executes do
            r = matcher_with_pass_result(status: :ok)
            r.all         { executes }
            r.execute_matching_block
        end
    end

    def test_matching_all_beats_default_pass
        assert_executes do
            r = matcher_with_pass_result(status: :ok)
            r.pass     { flunk }
            r.all(:ok) { executes }
            r.execute_matching_block
        end

        # Differing call order
        assert_executes do
            r = matcher_with_pass_result(status: :ok)
            r.all(:ok) { executes }
            r.pass     { flunk }
            r.execute_matching_block
        end
    end

    def test_matching_pass_beats_matching_all
        assert_executes do
            r = matcher_with_pass_result(status: :ok)
            r.pass(:ok) { executes }
            r.all(:ok)  { flunk }
            r.execute_matching_block
        end

        # Differing call order
        assert_executes do
            r = matcher_with_pass_result(status: :ok)
            r.all(:ok)  { flunk }
            r.pass(:ok) { executes }
            r.execute_matching_block
        end
    end

    def test_default_pass_beats_default_all
        assert_executes do
            r = matcher_with_pass_result(status: :ok)
            r.pass { executes }
            r.all  { flunk }
            r.execute_matching_block
        end
    end

    # TODO: Move me to test helpers
    def test_assert_executes
        assert_executes do
            executes
        end

        assert_not_executes do
        end

        refute_executes do
            assert_executes do
                assert_executes do
                    assert_not_executes do
                    end

                    executes
                end

                executes
            end
        end
    end

    private

    def assert_executes(message = "The given block did not execute the desired statement", &block)
        @assert_executes_stack ||= []
        @assert_executes_stack << false

        yield

        assert @assert_executes_stack.pop, message
    end

    def assert_not_executes(message = "The given block executed the statement it should not have executed", &block)
        @assert_executes_stack ||= []
        @assert_executes_stack << false

        yield

        refute @assert_executes_stack.pop, message
    end

    alias refute_executes assert_not_executes
    alias refute_not_executes assert_executes # please nobody ever use this.

    def executes
        @assert_executes_stack[-1] = true
    end

    def matcher_with_pass_result(status: :default)
        result = Slayer::Result.new(5, status, "my message")

        Slayer::ResultMatcher.new(result, NoArgCommand.new)
    end

    def matcher_with_fail_result(status: :default)
        result = Slayer::Result.new(5, status, "my message")
        begin
            result.fail!
        rescue Slayer::CommandFailure
        end

        Slayer::ResultMatcher.new(result, NoArgCommand.new)
    end
end
