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

  before { allow(user).to receive :touch }

  context 'no changes' do
    it do
      expect { subject }.to_not change Achievement, :count
      expect(achievement.reload).to be_persisted
      expect(achievement_2.reload).to be_persisted
      expect(user).to_not have_received :touch
    end
  end

  context 'added' do
    let(:added) do
      [
        Neko::AchievementData.new(
          user_id: user.id,
          neko_id: Types::Achievement::NekoId[:test],
          level: 1,
          progress: 0
        )
      ]
    end
    it do
      expect { subject }.to change(Achievement, :count).by 1
      expect(user.achievements.last).to have_attributes added[0].to_h.except(:neko_id)
      expect(user.achievements.last.neko_id).to eq added[0].neko_id
      expect(user).to have_received :touch
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
    end
  end
end
