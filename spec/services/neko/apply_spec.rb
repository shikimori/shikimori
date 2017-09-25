describe Neko::Apply do
  subject do
    Neko::Apply.call user,
      added: added,
      updated: updated,
      removed: removed
  end

  let(:user) { seed :user }
  let!(:achievement) { create :achievement, user: user }
  let(:added) { [] }
  let(:updated) { [] }
  let(:removed) { [] }

  describe 'add' do
    it do
      expect { subject }.to change(Achievement, :count).by 1
    end
  end

  describe 'update' do
    it do
      expect { subject }.to_not change Achievement, :count
    end
  end

  describe 'remove' do
    it do
      expect { subject }.to change(Achievement, :count).by -1
    end
  end
end
