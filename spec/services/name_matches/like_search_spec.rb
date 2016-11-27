describe NameMatches::LikeSearch do
  let(:service) { NameMatches::LikeSearch.new scope, phrase }

  let!(:anime_1) { create :anime, name: 'Tes' }
  let!(:anime_2) { create :anime, name: 'Tea' }
  let!(:anime_3) { create :anime, name: 'Tar' }

  before { NameMatches::Refresh.new.perform Anime.name }

  describe '#call' do
    subject { service.call }

    describe 'filter by phrase' do
      let(:scope) { Anime.all }
      let(:phrase) { 'te' }

      it { is_expected.to eq [anime_2, anime_1] }
    end
  end
end
