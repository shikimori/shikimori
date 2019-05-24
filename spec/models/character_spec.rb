# frozen_string_literal: true

describe Character do
  describe 'relations' do
    it { is_expected.to have_many(:person_roles).dependent :destroy }
    it { is_expected.to have_many :animes }
    it { is_expected.to have_many :mangas }
    it { is_expected.to have_many :people }

    it { is_expected.to have_attached_file :image }

    it { is_expected.to have_many(:cosplay_gallery_links).dependent :destroy }
    it { is_expected.to have_many :cosplay_galleries }

    it { is_expected.to have_many(:contest_winners).dependent :destroy }
  end

  it_behaves_like :touch_related_in_db_entry, :character
  it_behaves_like :topics_concern, :character
  it_behaves_like :collections_concern
  it_behaves_like :versions_concern
  it_behaves_like :clubs_concern, :character
end
