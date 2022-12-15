class TryCommand < Slayer::Command
  def call(value:, succeed: false)
    v = try! do
      next pass value: value if succeed
      next err value: value unless succeed
    end

    pass value: v
  end
end
