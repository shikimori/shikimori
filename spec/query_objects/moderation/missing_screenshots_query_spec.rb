describe Moderation::MissingScreenshotsQuery do
  let(:query) { Moderation::MissingScreenshotsQuery.new }

  describe '#fetch' do
    let!(:anime) { create :anime, :released, episodes: 2, score: 8 }
    let!(:user_rate) { create :user_rate, target: anime }

    context 'present screenshots' do
      let!(:screenshot) { create :screenshot, anime: anime }
      it { expect(query.fetch).to be_empty }
    end

    context 'missing screenshots' do
      it { expect(query.fetch).to eq [anime] }
    end

    context 'anons' do
      let!(:anime) { create :anime, :anons }
      it { expect(query.fetch).to be_empty }
    end
  end
end
