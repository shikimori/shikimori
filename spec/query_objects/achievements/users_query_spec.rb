describe Achievements::UsersQuery do
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

  context '.new' do
    subject do
      described_class.new(scope).filter(
        neko_id: rule.neko_id,
        level: rule.level
      )
    end

    describe '#filter' do
      let(:scope) { User.all }
      it { is_expected.to eq [user, user_2] }

      context 'sample' do
        let(:scope) { User.where(id: user_2.id) }
        it { is_expected.to eq [user_2] }
      end
    end
  end

  context '.fetch' do
    subject do
      described_class.fetch(fetched_user).filter(
        neko_id: rule.neko_id,
        level: rule.level
      )
    end

    describe '#filter' do
      let(:fetched_user) { nil }
      it { is_expected.to eq [user, user_2] }

      context 'banned user' do
        before do
          user.update! roles: [Types::User::ROLES_EXCLUDED_FROM_STATISTICS.sample]
        end

        it { is_expected.to eq [user_2] }

        context 'user not set' do
          let(:fetched_user) { nil }
          it { is_expected.to eq [user_2] }
        end

        context 'user is set' do
          context 'set banned user' do
            let(:fetched_user) { user }
            it { is_expected.to eq [user, user_2] }
          end

          context 'set not banned user' do
            let(:fetched_user) { user_2 }
            it { is_expected.to eq [user_2] }
          end
        end
      end
    end
  end
end
