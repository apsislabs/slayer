class TryCommand < Slayer::Command
  def call(value:, succeed: false)
    v = try! do
      next pass value: value if succeed
      next fail value: value unless succeed
    end

    return pass value: v
  end
end
