# frozen_string_literal: true

describe Manga do
  describe 'relations' do
    it { is_expected.to have_and_belong_to_many :genres }
    it { is_expected.to have_and_belong_to_many :publishers }

    it { is_expected.to have_many :person_roles }
    it { is_expected.to have_many :characters }
    it { is_expected.to have_many :people }

    it { is_expected.to have_many :rates }

    it { is_expected.to have_many :related }
    it { is_expected.to have_many :related_mangas }
    it { is_expected.to have_many :related_animes }

    it { is_expected.to have_many :similar }
    it { is_expected.to have_many :similar_mangas }

    it { is_expected.to have_many :user_histories }

    it { is_expected.to have_many :cosplay_gallery_links }
    it { is_expected.to have_many :cosplay_galleries }

    it { is_expected.to have_many :reviews }

    it { is_expected.to have_attached_file :image }

    it { is_expected.to have_many :recommendation_ignores }
    it { is_expected.to have_many :manga_chapters }

    it { is_expected.to have_many :name_matches }

    it { is_expected.to have_many :external_links }
    it { is_expected.to have_one :anidb_external_link }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:type).in :Manga, :Ranobe }
    it { is_expected.to enumerize(:kind).in :doujin, :manga, :manhua, :manhwa, :novel, :one_shot }
    it { is_expected.to enumerize(:status).in :anons, :ongoing, :released }
  end

  describe 'scopes' do
    describe '#read_manga' do
      before do
        [nil, 'rm_katana', 'am_love_knot'].each do |read_manga_id|
          create :manga, read_manga_id: read_manga_id
        end
      end

      it { expect(Manga.read_manga).to have(1).item }
      it { expect(Manga.read_manga.first.read_manga_id).to eq 'rm_katana' }
    end

    describe '#read_manga_adult' do
      before do
        [nil, 'rm_katana', 'am_love_knot'].each do |read_manga_id|
          create :manga, read_manga_id: read_manga_id
        end
      end

      it { expect(Manga.read_manga_adult).to have(1).item }
      it { expect(Manga.read_manga_adult.first.read_manga_id).to eq 'am_love_knot' }
    end
  end

  describe 'callbacks' do
    describe '#set_type' do
      let(:manga) { create :manga, kind: kind }

      context 'not set' do
        let(:kind) { nil }
        it { expect(manga.type).to eq Manga.name }
      end

      context 'not novel' do
        let(:kind) { %i[manga manhwa manhua one_shot doujin].sample }
        it { expect(manga.type).to eq Manga.name }
      end

      context 'novel' do
        let(:kind) { :novel }
        it { expect(manga.type).to eq Ranobe.name }
      end
    end
  end

  it_behaves_like :touch_related_in_db_entry, :manga
  it_behaves_like :topics_concern_in_db_entry, :manga
  it_behaves_like :collections_concern_in_db_entry, :manga
  it_behaves_like :elasticsearch_concern, :manga
end
