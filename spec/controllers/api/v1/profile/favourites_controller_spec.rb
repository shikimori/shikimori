require 'spec_helper'

describe Api::V1::Profile::FavouritesController do
  let(:user) do
    create :user,
      fav_animes: [create(:anime)],
      fav_mangas: [create(:manga)],
      fav_characters: [create(:character)],
      fav_persons: [create(:person)],
      fav_mangakas: [create(:person)],
      fav_producers: [create(:person)],
      fav_seyu: [create(:person)]
  end
  before { sign_in user }

  describe :index do
    before { get :index }
    it { should respond_with :success }
  end
end
