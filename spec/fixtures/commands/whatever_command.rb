class WhateverCommand < Slayer::Command
  def call(succeed:, value: nil, message: nil, status: nil)
    return err value: value, message: message, status: status unless succeed

    pass value: value, message: message, status: status
  end
end
