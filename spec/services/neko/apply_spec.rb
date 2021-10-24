describe Neko::Apply do
  subject do
    Neko::Apply.call user,
      added: added,
      updated: updated,
      removed: removed
  end

  let!(:achievement) do
    create :achievement,
      user: user,
      neko_id: Types::Achievement::NekoId[:animelist],
      level: 1,
      progress: 0
  end
  let!(:achievement_2) do
    create :achievement,
      user: build_stubbed(:user),
      neko_id: Types::Achievement::NekoId[:animelist],
      level: 1,
      progress: 0
  end
  let(:added) { [] }
  let(:updated) { [] }
  let(:removed) { [] }

  before do
    allow(user).to receive :touch
    allow(FayePublisher).to receive(:new).with(nil, nil).and_return faye_publisher
  end
  let(:faye_publisher) { double publish_achievements: nil }
  let(:achievements_url) { UrlGenerator.instance.profile_achievements_url(user) }

  context 'no changes' do
    it do
      expect { subject }.to_not change Achievement, :count
      expect(achievement.reload).to be_persisted
      expect(achievement_2.reload).to be_persisted
      expect(user).to_not have_received :touch
      expect(faye_publisher).to_not have_received :publish_achievements
    end
  end

  context 'added' do
    let(:added) do
      [
        Neko::AchievementData.new(
          user_id: user.id,
          neko_id: Types::Achievement::NekoId[:test],
          level: 0,
          progress: 0
        ),
        Neko::AchievementData.new(
          user_id: user.id,
          neko_id: Types::Achievement::NekoId[:test],
          level: 1,
          progress: 0
        )
      ]
    end
    it do
      expect { subject }.to change(Achievement, :count).by 2
      expect(user.achievements.last).to have_attributes added[1].to_h.except(:neko_id)
      expect(user.achievements.last.neko_id).to eq added[1].neko_id
      expect(user).to have_received :touch

      expect(faye_publisher)
        .to have_received(:publish_achievements)
        .once
        .with(
          [{
            label: 'Нет названия',
            neko_id: :test,
            level: 0,
            image: nil,
            event: :gained
          }],
          user.faye_channels
        )
    end
  end

  context 'updated' do
    let(:updated) do
      [
        Neko::AchievementData.new(
          user_id: user.id,
          neko_id: achievement.neko_id,
          level: achievement.level,
          progress: achievement.progress + 1
        )
      ]
    end
    it do
      expect { subject }.to_not change Achievement, :count
      expect(achievement.reload).to have_attributes updated[0].to_h.except(:neko_id)
      expect(achievement.neko_id).to eq updated[0].neko_id
      expect(user).to have_received :touch
      expect(faye_publisher).to_not have_received :publish_achievements
    end
  end

  context 'removed' do
    let(:removed) do
      [
        Neko::AchievementData.new(
          user_id: user.id,
          neko_id: achievement.neko_id,
          level: achievement.level,
          progress: achievement.progress + 1
        )
      ]
    end
    it do
      expect { subject }.to change(Achievement, :count).by(-1)
      expect { achievement.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(user).to have_received :touch
      expect(faye_publisher)
        .to have_received(:publish_achievements)
        .once
        .with(
          [{
            label: 'Добро пожаловать!',
            neko_id: :animelist,
            level: 1,
            image: '/assets/achievements/anime/animelist_1.png',
            event: :lost
          }],
          user.faye_channels
        )
    end
  end
end
