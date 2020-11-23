describe Achievements::UsersQuery do
  subject { described_class.new(scope).call rule.neko_id, rule.level }

  let(:rule) do
    Neko::Rule.new(
      neko_id: neko_id,
      level: 1,
      image: '',
      border_color: nil,
      title_ru: 'zxc',
      text_ru: 'vbn',
      title_en: nil,
      text_en: nil,
      topic_id: nil,
      rule: {
        threshold: 15,
        filters: {}
      }
    )
  end
  let(:neko_id) { Types::Achievement::NekoId[:test] }
  let!(:achievement_1) do
    create :achievement,
      neko_id: rule.neko_id,
      level: rule.level,
      user: user
  end
  let!(:achievement_2) do
    create :achievement,
      neko_id: rule.neko_id,
      level: rule.level,
      user: user_2
  end

  let!(:achievement_3) do
    create :achievement,
      neko_id: Types::Achievement::NekoId[:animelist],
      level: rule.level,
      user: user_3
  end
  let!(:achievement_4) do
    create :achievement,
      neko_id: rule.neko_id,
      level: rule.level + 1,
      user: user_3
  end

  let(:scope) { User.all }
  it { is_expected.to eq [user, user_2] }

  context 'sample' do
    let(:scope) { User.where(id: user_2.id) }
    it { is_expected.to eq [user_2] }
  end
end
