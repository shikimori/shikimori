require 'spec_helper'

describe Manga do
  context :relations do
    it { should have_and_belong_to_many :genres }
    it { should have_and_belong_to_many :publishers }

    it { should have_many :person_roles }
    it { should have_many :characters }
    it { should have_many :people }

    it { should have_many :rates }
    it { should have_many :topics }
    it { should have_many :news }

    it { should have_many :related }
    it { should have_many :related_mangas }
    it { should have_many :related_animes }

    it { should have_many :similar }

    it { should have_one :thread }

    it { should have_many :user_histories }

    it { should have_many :cosplay_gallery_links }
    it { should have_many :cosplay_galleries }

    it { should have_many :reviews }

    it { should have_many :images }
    it { should have_attached_file :image }

    it { should have_many :recommendation_ignores }
    it { should have_many :manga_chapters }
  end
end
