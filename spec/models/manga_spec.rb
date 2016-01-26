describe Manga do
  describe 'relations' do
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

    it { should have_attached_file :image }

    it { should have_many :recommendation_ignores }
    it { should have_many :manga_chapters }

    it { is_expected.to have_many :name_matches }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in :doujin, :manga, :manhua, :manhwa, :novel, :one_shot }
    it { is_expected.to enumerize(:status).in :anons, :ongoing, :released }
  end

  describe 'scopes' do
    before do
      [nil, 'rm_katana', 'am_love_knot'].each do |read_manga_id|
        create :manga, read_manga_id: read_manga_id
      end
    end

    describe '#read_manga' do
      it { expect(Manga.read_manga).to have(1).item }
      it { expect(Manga.read_manga.first.read_manga_id).to eq 'rm_katana' }
    end

    describe '#read_manga_adult' do
      it { expect(Manga.read_manga_adult).to have(1).item }
      it { expect(Manga.read_manga_adult.first.read_manga_id).to eq 'am_love_knot' }
    end
  end
end
