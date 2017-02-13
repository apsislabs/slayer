module Slayer
  # ResultMatcher is the object passed to the block of a {Command.call}. The ResultMatcher
  # allows the block-author to specify which piece of logic they would like to invoke
  # based on the state of the {Result} object.
  #
  # In the event that multiple blocks match the {Result}, only the most specific
  # matching block will be invoked. Status matches take precedence over default matches.
  # If there are two blocks with a matching status, the pass/fail block takes precedence
  # over the all block.
  #
  # == Matching based on success or failure
  #
  # The ResultMatcher matches calls to {#pass} to a {Result} that returns +true+
  # for {Result#success?}, calls to {#fail} to a {Result} that returns +true+
  # for {Result#failure?}, and calls to {#all} to a {Result} in either state.
  #
  # A matching call to {#pass} or {#fail} takes precedence over matching calls to {#all}
  #
  # == Matching based on status
  #
  # Additionally, the ResultMatcher can also match by the {Result#status}. If a status
  # or statuses is passed to {#pass}, {#fail}, or {#all}, these will only be invoked if the
  # status of the {Result} matches the passed in status.
  #
  # If the default block is the same as the block for one of the statuses the status +:default+
  # can be used to indicate which block should be used as the default. Successful status matches
  # take precedence over default matchers.
  #
  # == Both pass and fail must be handled
  #
  # If the block form of a {Command.call} is invoked, both the block must handle the default
  # status for both a {Result#success?} and a {Result#failure?}. If both are not handled,
  # the matching block will not be invoked and a {CommandResultNotHandledError} will be
  # raised.
  #
  # @example Matcher invokes the matching pass block, with precedence given to {#pass} and {#fail}
  #   # Call produces a successful Result
  #   SuccessCommand.call do |m|
  #     m.pass { puts "Pass!" }
  #     m.fail { puts "Fail!" }
  #     m.all  { puts "All!"  } # will never be invoked, due to both a pass and fail response existing
  #   end
  #   # => prints "Pass!"
  #
  # @example Matcher invokes the matching status of the result object, or the default
  #   # Call produces a successful Result with status :ok
  #   SuccessCommand.call do |m|
  #     m.pass(:ok) { puts "Pass, OK!" }
  #     m.pass      { puts "Pass, default!" }
  #     m.fail      { puts "Fail!" }
  #   end
  #   # => prints "Pass, OK!"
  #
  #   # Call produces a successful Result with status :created
  #   SuccessCommand.call do |m|
  #     m.pass(:ok) { puts "Pass, OK!" }
  #     m.pass      { puts "Pass, default!" }
  #     m.fail      { puts "Fail!" }
  #   end
  #   # => prints "Pass, default!"
  #
  # @example Matcher invokes the explicitly indicated default block
  #   # Call produces a successful Result with status :created
  #   SuccessCommand.call do |m|
  #     m.pass(:ok, :default) { puts "Pass, OK!" }
  #     m.pass(:great)        { puts "Pass, default!" }
  #     m.fail                { puts "Fail!" }
  #   end
  #   # => prints "Pass, OK!"
  #
  # @example Matcher must handle both pass and fail defaults.
  #   # Call produces a successful Result with status :ok
  #   SuccessCommand.call do |m|
  #     m.pass(:ok) { puts "Pass, OK!"}
  #     m.fail      { puts "Fail!" }
  #   end
  #   # => raises CommandResultNotHandledError (because no default pass was provided)
  #
  #   # Call produces a successful Result with status :ok
  #   SuccessCommand.call do |m|
  #     m.pass(:ok, :default) { puts "Pass, OK!"}
  #     m.fail                { puts "Fail!" }
  #   end
  #   # => prints "Pass, OK!"
  #
  #   # Call produces a successful Result with status :ok
  #   SuccessCommand.call do |m|
  #     m.pass(:ok) { puts "Pass, OK!"}
  #     m.all       { puts "All!" }
  #   end
  #   # => prints "Pass, OK!"
  #
  #   # Call produces a successful Result with status :ok
  #   SuccessCommand.call do |m|
  #     m.pass(:ok, :default) { puts "Pass, OK!"}
  #   end
  #   # => raises CommandResultNotHandledError (because no default fail was provided)
  class ResultMatcher
    attr_reader :result, :command

    # @api private
    def initialize(result, command)
      @result = result
      @command = command

      @status = result.status || :default

      @handled_default_pass = false
      @handled_default_fail = false

      # These are set to false if they are never set. If they are set to `nil` that
      # means the block intentionally passed `nil` as the block to be executed.
      @matching_block       = false
      @matching_all         = false
      @default_block        = false
      @default_all          = false
      @ensure_block         = false
    end

    # Provide a block that should be invoked if the {Result} is a success.
    #
    # @param statuses [Array<status>] Statuses that should be compared to the {Result}. If
    #   any of provided statuses match the {Result} this block will be considered a match.
    #   The symbol +:default+ can also be used to indicate that this should match any {Result}
    #   not matched by other matchers.
    #
    #   If no value is provided for statuses it defaults to +:default+.
    def pass(*statuses, &block)
      statuses << :default if statuses.empty?
      @handled_default_pass ||= statuses.include?(:default)

      block_is_match   = @result.success? && statuses.include?(@status)
      block_is_default = @result.success? && statuses.include?(:default)

      @matching_block = block if block_is_match
      @default_block  = block if block_is_default
    end

    # Provide a block that should be invoked if the {Result} is a failure.
    #
    # @param statuses [Array<status>] Statuses that should be compared to the {Result}. If
    #   any of provided statuses match the {Result} this block will be considered a match.
    #   The symbol +:default+ can also be used to indicate that this should match any {Result}
    #   not matched by other matchers.
    #
    #   If no value is provided for statuses it defaults to +:default+.
    def fail(*statuses, &block)
      statuses << :default if statuses.empty?
      @handled_default_fail ||= statuses.include?(:default)

      block_is_match   = @result.failure? && statuses.include?(@status)
      block_is_default = @result.failure? && statuses.include?(:default)

      @matching_block = block if block_is_match
      @default_block  = block if block_is_default
    end

    # Provide a block that should be invoked for any {Result}. This has a lower precedence that
    # either {#pass} or {#fail}.
    #
    # @param statuses [Array<status>] Statuses that should be compared to the {Result}. If
    #   any of provided statuses match the {Result} this block will be considered a match.
    #   The symbol +:default+ can also be used to indicate that this should match any {Result}
    #   not matched by other matchers.
    #
    #   If no value is provided for statuses it defaults to +:default+.
    def all(*statuses, &block)
      statuses << :default if statuses.empty?
      @handled_default_pass ||= statuses.include?(:default)
      @handled_default_fail ||= statuses.include?(:default)

      block_is_match   = statuses.include?(@status)
      block_is_default = statuses.include?(:default)

      @matching_all = block if block_is_match
      @default_all  = block if block_is_default
    end

    # Provide a block that should be always be invoked after other blocks have executed. This block
    # will be invoked even if the other block raises an error.
    def ensure(&block)
      @ensure_block = block
    end

    # @return Whether both the pass and the fail defaults have been handled.
    #
    # @api private
    def handled_defaults?
      return @handled_default_pass && @handled_default_fail
    end

    # Executes the provided block that best matched the {Result}. If no block matched
    # nothing is executed
    #
    # @api private
    def execute_matching_block
      if @matching_block != false # nil should pass this test
        @matching_block&.call(@result, @command) # explicit nil will not get called with
                                                 # safe navigation (&.)
      elsif @matching_all != false
        @matching_all&.call(@result, @command)
      elsif @default_block != false
        @default_block&.call(@result, @command)
      elsif @default_all
        @default_all&.call(@result, @command)
      end
    end

    def execute_ensure_block
      # rubocop:disable Style/IfUnlessModifier
      if @ensure_block != false # nil should pass this test
        @ensure_block.call(@result, @command)
      end
      # rubocop:enable Style/IfUnlessModifier
    end
  end
end
