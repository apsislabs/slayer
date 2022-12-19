class TryCommand < Slayer::Command
  def call(value:, succeed: false)
    v = try! do
      next ok value: value if succeed
      next err value: value unless succeed
    end

    ok value: v
  end
end
