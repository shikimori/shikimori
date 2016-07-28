describe UserRates::RefreshIrrelevant do
  let(:service) { UserRates::RefreshIrrelevant.new library, Anime }

  describe '#perform' do
    let!(:library) do
      {
        planned: OpenStruct.new(user_rates: [anons_rate, released_rate]),
        watching: OpenStruct.new(user_rates: [ongoing_rate])
      }
    end
    let(:anons_rate) { create :user_rate, anime: anons }
    let(:released_rate) { create :user_rate, anime: released }
    let(:ongoing_rate) { create :user_rate, anime: ongoing }

    let(:anons) { create :anime, :anons, episodes: 20 }
    let(:released) { create :anime, :released, episodes: 20 }
    let(:ongoing) { create :anime, :ongoing, episodes: 20 }

    before do
      Anime.find(anons.id).update episodes_aired: 10
      Anime.find(released.id).update episodes_aired: 11
      Anime.find(ongoing.id).update episodes_aired: 12
    end
    subject! { service.call }

    it do
      expect(library[:planned].user_rates.first.anime.episodes_aired).to eq 10
      expect(library[:planned].user_rates.second.anime.episodes_aired).to eq 0
      expect(library[:watching].user_rates.first.anime.episodes_aired).to eq 12
    end
  end
end
