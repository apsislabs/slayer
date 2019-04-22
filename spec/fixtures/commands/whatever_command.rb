class WhateverCommand < Slayer::Command
  def call(value: nil, message: nil, status: nil, succeed:)
    flunk! value: value, message: message, status: status unless succeed

    pass value: value, message: message, status: status
  end
end
