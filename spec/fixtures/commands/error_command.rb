class ErrorCommand < Slayer::Command
  def call
    raise ArgumentError, 'Error Raised on Purpose'
  end
end
