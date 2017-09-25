describe Neko::Request, :vcr do
  subject { Neko::Request.call params }
  let(:params) { { user_id: 1, action: Types::Neko::Action[:noop] } }

  it do
    is_expected.to eq(
      updated: [],
      removed: [
        Neko::AchievementData.new(
          user_id: 1,
          progress: 0,
          neko_id: Types::Achievement::NekoId[:test],
          level: 1
        )
      ],
      added: [
        Neko::AchievementData.new(
          user_id: 1,
          progress: 100,
          neko_id: Types::Achievement::NekoId[:animelist],
          level: 0
        ),
        Neko::AchievementData.new(
          user_id: 1,
          progress: 100,
          neko_id: Types::Achievement::NekoId[:animelist],
          level: 1
        ),
        Neko::AchievementData.new(
          user_id: 1,
          progress: 100,
          neko_id: Types::Achievement::NekoId[:animelist],
          level: 2
        ),
        Neko::AchievementData.new(
          user_id: 1,
          progress: 100,
          neko_id: Types::Achievement::NekoId[:animelist],
          level: 3
        ),
        Neko::AchievementData.new(
          user_id: 1,
          progress: 70,
          neko_id: Types::Achievement::NekoId[:animelist],
          level: 4
        )
      ]
    )
  end
end
