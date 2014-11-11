describe FavouritesQuery do
  let(:person) { create :person, name: 'test', mangaka: true }

  let!(:user_1) { create :user, favourite_persons: [create(:favourite, linked: person)] }
  let!(:user_2) { create :user, favourite_persons: [create(:favourite, linked: person)] }
  let!(:user_3) { create :user, favourite_persons: [create(:favourite, linked: person)] }
  let!(:user_4) { create :user }

  let(:query) { FavouritesQuery.new }

  describe :favoured_by do
    it { expect(query.favoured_by(person, 2).size).to eq(2) }
    it { expect(query.favoured_by(person, 99).size).to eq(3) }
  end

  describe :top_entries do
    let(:person_2) { create :person, name: 'test', mangaka: true }
    let(:person_3) { create :person, name: 'test', mangaka: true }

    let!(:user_5) { create :user, favourite_persons: [create(:favourite, linked: person_2)] }
    let!(:user_6) { create :user, favourite_persons: [create(:favourite, linked: person_2)] }
    let!(:user_7) { create :user, favourite_persons: [create(:favourite, linked: person_3)] }

    it { expect(query.top_favourite_ids Person, 2).to eq [person.id, person_2.id] }
  end
end
