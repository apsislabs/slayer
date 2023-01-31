require 'rubocop'

module Slayer
  class CommandReturn < RuboCop::Cop::Base
    def_node_search :explicit_returns, 'return'
    def_node_matcher :slayer_command?, '(class (const (const nil :Slayer) :Command) _)'
    def_node_matcher :is_call_to_pass?, '(send nil :pass ?)'
    def_node_matcher :is_call_to_flunk?, '(send nil :flunk! ?)'

    def on_def(node)
      return unless node.method?(:call)
      return unless in_slayer_command?(node)

      explicit_returns(node) do |n|
        validate_return! n.child_nodes.first, n
      end

      # Temporarily does not look at implicit returns
      #
      # implicit_returns(node) do |node|
      #   validate_return! node
      # end
    end

    private

    # Continue traversing `node` until you get to the last expression.
    # If that expression is a call to `.can_see?`, then add an offense.
    def implicit_returns(_node)
      raise 'Not Implemented Yet'
    end

    def in_slayer_command?(node)
      node.ancestors.any?(&:slayer_command?)
    end

    def validate_return!(node, return_node = nil)
      return if is_call_to_pass? node
      return if is_call_to_flunk? node

      add_offense(return_node || node,
                  message: 'call in Slayer::Command must return the result of `pass` or call `flunk!`')
    end
  end
end
