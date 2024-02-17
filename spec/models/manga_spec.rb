# frozen_string_literal: true

describe Manga do
  describe 'relations' do
    it { is_expected.to have_one :poster }
    it { is_expected.to have_many(:posters).dependent :destroy }

    it { is_expected.to have_many(:person_roles).dependent(:destroy) }
    it { is_expected.to have_many :characters }
    it { is_expected.to have_many :people }

    it { is_expected.to have_many :rates }
    it { is_expected.to have_many(:user_rate_logs).dependent(:destroy) }

    it { is_expected.to have_many(:related).dependent(:destroy) }
    it { is_expected.to have_many :related_mangas }
    it { is_expected.to have_many :related_animes }

    it { is_expected.to have_many(:similar).dependent(:destroy) }
    it { is_expected.to have_many :similar_mangas }

    it { is_expected.to have_many(:user_histories).dependent(:destroy) }
    it { is_expected.to have_many(:reviews).dependent :destroy }

    it { is_expected.to have_many :cosplay_gallery_links }
    it { is_expected.to have_many :cosplay_galleries }

    it { is_expected.to have_many(:critiques).dependent(:destroy) }

    it { is_expected.to have_attached_file :image }

    it { is_expected.to have_many(:recommendation_ignores).dependent(:destroy) }

    it { is_expected.to have_many(:name_matches).dependent(:destroy) }

    it { is_expected.to have_many :external_links }
    it { is_expected.to have_many(:all_external_links).dependent(:destroy) }
    it { is_expected.to have_one :anidb_external_link }

    it { is_expected.to have_one(:stats).dependent :destroy }
    it { is_expected.to have_many(:anime_stat_histories).dependent :destroy }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:description_ru).is_at_most(16384) }
    it { is_expected.to validate_length_of(:description_en).is_at_most(16384) }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:type).in :Manga, :Ranobe }
    it { is_expected.to enumerize(:kind).in(*Types::Manga::Kind.values) }
    it { is_expected.to enumerize(:status).in(*Types::Manga::Status.values) }
  end

  describe 'callbacks' do
    describe '#set_type' do
      let(:manga) { create :manga, kind: }

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

    describe '#actualize_is_censored, #actualize_ranked' do
      include_context :reset_repository, MangaGenresV2Repository, true
      before do
        allow(DbEntry::CensoredPolicy)
          .to receive(:censored?)
          .with(instance_of(Manga))
          .and_return is_censored
      end
      let(:is_censored) { [true, false].sample }

      subject do
        create :manga,
          genre_v2_ids: [genre_v2.id],
          is_censored: false,
          desynced:,
          ranked:
      end
      let!(:genre_v2) { create :genre_v2 }
      let(:desynced) { [] }
      let(:ranked) { 5 }

      its(:is_censored) { is_expected.to eq is_censored }
      its(:ranked) { is_expected.to eq is_censored ? 0 : ranked }

      context 'is_censored in desynced' do
        let(:desynced) { ['is_censored'] }
        its(:is_censored) { is_expected.to eq false }
      end
    end

    describe '#sync_topics_is_censored' do
      let(:entry) { create :manga, :with_sync_topics_is_censored }
      before do
        allow(Animes::SyncTopicsIsCensored).to receive :call
        entry.update is_censored: !entry.is_censored
      end

      it do
        expect(Animes::SyncTopicsIsCensored)
          .to have_received(:call)
          .with entry
      end
    end
  end

  describe 'instance methods' do
    describe '#genres' do
      let(:genre) { create :genre, :manga }
      let(:manga) { build :manga, genre_ids: [genre.id] }

      it { expect(manga.genres).to eq [genre] }
    end

    describe '#genres_v2' do
      let(:genre) { create :genre_v2, :manga }
      let(:manga) { build :manga, genre_v2_ids: [genre.id] }

      it { expect(manga.genres_v2).to eq [genre] }
    end

    describe '#publishers' do
      let(:publisher) { create :publisher }
      let(:manga) { build :manga, publisher_ids: [publisher.id] }

      it { expect(manga.publishers).to eq [publisher] }
    end

    describe '#rkn_abused?' do
      before { subject.id = id }

      context 'matched id' do
        let(:id) { Copyright::ABUSED_BY_RKN_MANGA_IDS.sample }
        its(:rkn_abused?) { is_expected.to eq true }
      end

      context 'not matched id' do
        let(:id) { 9999999 }
        its(:rkn_abused?) { is_expected.to eq false }
      end
    end

    describe '#rkn_banned?' do
      before { subject.id = id }

      context 'matched id' do
        let(:id) { Copyright::BANNED_BY_RKN_MANGA_IDS.sample }
        its(:rkn_abused?) { is_expected.to eq true }
      end

      context 'not matched id' do
        let(:id) { 9999999 }
        its(:rkn_abused?) { is_expected.to eq false }
      end
    end
  end

  it_behaves_like :touch_related_in_db_entry, :manga
  it_behaves_like :topics_concern, :manga
  it_behaves_like :collections_concern
  it_behaves_like :versions_concern
  it_behaves_like :clubs_concern, :manga
  it_behaves_like :contests_concern
  it_behaves_like :favourites_concern
  it_behaves_like :computed_incomplete_date_field, :manga, :aired_on
end
