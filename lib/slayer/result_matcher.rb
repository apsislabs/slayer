module Slayer
  class ResultMatcher
    attr_reader :result, :command

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
    end

    def pass(*statuses, &block)
      statuses << :default if statuses.empty?
      @handled_default_pass ||= statuses.include?(:default)

      block_is_match   = @result.success? && statuses.include?(@status)
      block_is_default = @result.success? && statuses.include?(:default)

      @matching_block = block if block_is_match
      @default_block  = block if block_is_default
    end

    def fail(*statuses, &block)
      statuses << :default if statuses.empty?
      @handled_default_fail ||= statuses.include?(:default)

      block_is_match   = @result.failure? && statuses.include?(@status)
      block_is_default = @result.failure? && statuses.include?(:default)

      @matching_block = block if block_is_match
      @default_block  = block if block_is_default
    end

    def all(*statuses, &block)
      statuses << :default if statuses.empty?
      @handled_default_pass ||= statuses.include?(:default)
      @handled_default_fail ||= statuses.include?(:default)

      block_is_match   = statuses.include?(@status)
      block_is_default = statuses.include?(:default)

      @matching_all = block if block_is_match
      @default_all  = block if block_is_default
    end

    def handled_defaults?
      return @handled_default_pass && @handled_default_fail
    end

    def execute_matching_block
      if @matching_block != false # nil should pass this test
        @matching_block.call(@result, @command) if @matching_block # nil should fail this test
      elsif @matching_all != false
        @matching_all.call(@result, @command) if @matching_all
      elsif @default_block != false
        @default_block.call(@result, @command) if @default_block
      elsif @default_all
        @default_all.call(@result, @command) if @default_all
      end
    end
  end
end
