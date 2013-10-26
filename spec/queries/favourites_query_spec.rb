require 'spec_helper'

describe FavouritesQuery do
  let(:person) { create :person, name: 'test', mangaka: true }

  before do
    create :user, favourite_persons: [create(:favourite, linked: person)]
    create :user, favourite_persons: [create(:favourite, linked: person)]
    create :user, favourite_persons: [create(:favourite, linked: person)]
    create :user
  end

  describe 'fetch' do
    it { FavouritesQuery.new(person, 2).fetch.should have(2).items  }
    it { FavouritesQuery.new(person, 99).fetch.should have(3).items  }
  end
end
