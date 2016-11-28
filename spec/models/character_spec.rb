# frozen_string_literal: true

describe Character do
  describe 'relations' do
    it { is_expected.to have_many :person_roles }
    it { is_expected.to have_many :animes }
    it { is_expected.to have_many :mangas }
    it { is_expected.to have_many :people }
    it { is_expected.to have_many :japanese_roles }
    it { is_expected.to have_many :seyu }

    it { is_expected.to have_attached_file :image }

    it { is_expected.to have_many :cosplay_gallery_links }
    it { is_expected.to have_many :cosplay_galleries }
  end

  it_behaves_like :touch_related_in_db_entry, :character
  it_behaves_like :topics_concern_in_db_entry, :character
  it_behaves_like :elasticsearch_concern, :character
end
