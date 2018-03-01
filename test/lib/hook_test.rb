require 'test_helper'

class Slayer::HookTest < Minitest::Test
  def test_hook_runs_for_methods
    assert_executes { SimpleHook.new.simple { executes } }
    assert_executes { SimpleHook.simple { executes } }
  end

  def test_hook_does_not_run_for_skipped_methods
    refute_executes { SkipHooks.a { executes } }
    refute_executes { SkipHooks.new.a { executes } }
  end

  def test_hook_runs_for_classes_with_skipped_methods
    assert_executes { SkipHooks.c { executes } }
    assert_executes { SkipHooks.new.c { executes } }
  end

  def test_hook_runs_for_only_hooked_methods
    assert_executes { OnlyHook.a { executes } }
    assert_executes { OnlyHook.new.a { executes } }
  end

  def test_hook_does_not_run_for_classes_with_only_hooked_methods
    refute_executes { OnlyHook.c { executes } }
    refute_executes { OnlyHook.new.c { executes } }
  end

  def test_hook_does_not_run_for_classes_with_no_hooks
    refute_executes { NoHooks.a { executes } }
    refute_executes { NoHooks.new.a { executes } }
  end
end
