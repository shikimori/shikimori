describe Neko::Apply do
  subject do
    Neko::Apply.call user,
      added: added,
      updated: updated,
      removed: removed
  end

  let(:user) { seed :user }
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

  describe 'add' do
    let(:added) do
      [{
        neko_id: Types::Achievement::NekoId[:test].to_s,
        level: 1,
        progress: 0
      }]
    end
    it do
      expect { subject }.to change(Achievement, :count).by 1
      expect(user.achievements.last).to have_attributes added[0]
    end
  end

  describe 'update' do
    let(:updated) do
      [{
        neko_id: achievement.neko_id.to_s,
        level: achievement.level,
        progress: achievement.progress + 1,
      }]
    end
    it do
      expect { subject }.to_not change Achievement, :count
      expect(achievement.reload).to have_attributes updated[0]
    end
  end

  describe 'remove' do
    let(:removed) do
      [{
        neko_id: achievement.neko_id.to_s,
        level: achievement.level,
        progress: achievement.progress + 1,
      }]
    end
    it do
      expect { subject }.to change(Achievement, :count).by(-1)
      expect { achievement.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
