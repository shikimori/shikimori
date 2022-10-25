describe UserHistoryView do
  include_context :view_context_stub
  let(:view) { UserHistoryView.new user }

  let(:anime) { create :anime }
  let!(:history) { create :user_history, user: user, anime: anime }

  describe '#page' do
    it { expect(view.page).to eq 1 }
  end

  describe '#collection' do
    it do
      expect(view.collection).to have(1).item
      expect(view.collection[:today]).to have(1).item
      expect(view.collection[:today].first.object).to eq history
    end
  end

  describe '#add_postloader?' do
    it { expect(view.add_postloader?).to eq false }
  end
end
