# frozen_string_literal: true

describe Person do
  describe 'relations' do
    it { is_expected.to have_one :poster }
    it { is_expected.to have_many :person_roles }
    it { is_expected.to have_many :animes }
    it { is_expected.to have_many :mangas }
    it { is_expected.to have_many :characters }

    it { is_expected.to have_attached_file :image }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:japanese).is_at_most(255) }
  end

  it_behaves_like :touch_related_in_db_entry, :person
  it_behaves_like :topics_concern, :person
  it_behaves_like :collections_concern
  it_behaves_like :versions_concern
  it_behaves_like :clubs_concern, :person
  it_behaves_like :contests_concern
  it_behaves_like :favourites_concern
end
