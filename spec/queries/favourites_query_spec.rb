describe FavouritesQuery do
  let(:person) { create :person, name: 'test', mangaka: true }

  let!(:user_1) { create :user, favourite_persons: [create(:favourite, linked: person)] }
  let!(:user_2) { create :user, favourite_persons: [create(:favourite, linked: person)] }
  let!(:user_3) { create :user, favourite_persons: [create(:favourite, linked: person)] }
  let!(:user_4) { create :user }

  let(:query) { FavouritesQuery.new }

  describe 'favoured_by' do
    it { expect(query.favoured_by(person, 2).size).to eq(2) }
    it { expect(query.favoured_by(person, 99).size).to eq(3) }
  end

  describe 'top_entries' do
    let(:person_2) { create :person, name: 'test', mangaka: true }
    let(:person_3) { create :person, name: 'test', mangaka: true }

    let!(:user_5) { create :user, favourite_persons: [create(:favourite, linked: person_2)] }
    let!(:user_6) { create :user, favourite_persons: [create(:favourite, linked: person_2)] }
    let!(:user_7) { create :user, favourite_persons: [create(:favourite, linked: person_3)] }

    it { expect(query.top_favourite_ids Person, 2).to eq [person.id, person_2.id] }
  end

  describe 'global_top' do
    let(:anime_1) { create :anime }
    let(:anime_2) { create :anime }
    let(:anime_3) { create :anime }

    let!(:user_1) { create :user, favourite_persons: [create(:favourite, linked: anime_2)] }
    let!(:user_2) { create :user, favourite_persons: [create(:favourite, linked: anime_2)] }
    let!(:user_3) { create :user, favourite_persons: [create(:favourite, linked: anime_1)] }

    context 'without user' do
      it { expect(query.global_top Anime, 100, nil).to eq [anime_2, anime_1] }
    end

    context 'with user' do
      it { expect(query.global_top Anime, 100, user_4).to eq [anime_2, anime_1] }

      context 'anime in list' do
        let!(:user_rate) { create :user_rate, user: user_4, target: anime_2, status: 'watching' }
        it { expect(query.global_top Anime, 100, user_4).to eq [anime_1] }
      end

      context 'anime in recommendations ingnores' do
        let!(:recommendation_ignore) { create :recommendation_ignore, user: user_4, target: anime_2 }
        it { expect(query.global_top Anime, 100, user_4).to eq [anime_1] }
      end
    end
  end
end
