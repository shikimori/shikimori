# frozen_string_literal: true

describe Anime do
  describe 'relations' do
    it { is_expected.to have_many(:person_roles).dependent :destroy }
    it { is_expected.to have_many :characters }
    it { is_expected.to have_many :people }

    it { is_expected.to have_many :rates }
    it { is_expected.to have_many(:user_rate_logs).dependent(:destroy) }

    it { is_expected.to have_many(:user_histories).dependent :destroy }
    it { is_expected.to have_many(:reviews).dependent :destroy }

    it { is_expected.to have_many :news_topics }
    it { is_expected.to have_many :anons_news_topics }
    it { is_expected.to have_many :episode_news_topics }
    it { is_expected.to have_many :ongoing_news_topics }
    it { is_expected.to have_many :released_news_topics }

    it { is_expected.to have_many(:related).dependent :destroy }
    it { is_expected.to have_many :related_animes }
    it { is_expected.to have_many :related_mangas }

    it { is_expected.to have_many(:similar).dependent :destroy }
    it { is_expected.to have_many :similar_animes }

    it { is_expected.to have_many(:cosplay_gallery_links).dependent :destroy }
    it { is_expected.to have_many :cosplay_galleries }

    it { is_expected.to have_attached_file :image }

    it { is_expected.to have_many :screenshots }
    it { is_expected.to have_many(:all_screenshots).dependent :destroy }

    it { is_expected.to have_many :videos }
    it { is_expected.to have_many(:all_videos).dependent :destroy }

    it { is_expected.to have_many(:anime_calendars).dependent :destroy }

    it { is_expected.to have_many(:critiques).dependent :destroy }

    it { is_expected.to have_many(:recommendation_ignores).dependent :destroy }

    it { is_expected.to have_many(:anime_videos).dependent :destroy }
    it { is_expected.to have_many(:episode_notifications).dependent :destroy }

    it { is_expected.to have_many(:name_matches).dependent :destroy }

    it { is_expected.to have_many(:links).dependent :destroy }
    it { is_expected.to have_many :external_links }
    it { is_expected.to have_many(:all_external_links).dependent :destroy }
    it { is_expected.to have_one :anidb_external_link }
    it { is_expected.to have_one :smotret_anime_external_link }

    it { is_expected.to have_one(:stats).dependent :destroy }
    it { is_expected.to have_many(:anime_stat_histories).dependent :destroy }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:description_ru).is_at_most(16384) }
    it { is_expected.to validate_length_of(:description_en).is_at_most(16384) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:english).is_at_most(255) }
    it { is_expected.to validate_length_of(:russian).is_at_most(255) }
    it { is_expected.to validate_length_of(:japanese).is_at_most(255) }
    it { is_expected.to validate_length_of(:license_name_ru).is_at_most(255) }
    it { is_expected.to validate_length_of(:season).is_at_most(255) }
    it { is_expected.to validate_length_of(:franchise).is_at_most(255) }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in(*Types::Anime::Kind.values) }
    it { is_expected.to enumerize(:status).in(*Types::Anime::Status.values) }
    it { is_expected.to enumerize(:rating).in(*Types::Anime::Rating.values) }
    it { is_expected.to enumerize(:origin) }
    it { is_expected.to enumerize(:options).in(*Types::Anime::Options.values) }
  end

  describe 'callbacks' do
    describe 'news topics generation' do
      context 'news topics already generated' do
        let(:anime) { create :anime, :with_callbacks, status: :ongoing }

        let!(:ru_news_topic) do
          create :news_topic,
            linked: anime,
            action: AnimeHistoryAction::Anons,
            value: nil,
            locale: :ru
        end
        let!(:en_news_topic) do
          create :news_topic,
            linked: anime,
            action: AnimeHistoryAction::Anons,
            value: nil,
            locale: :en
        end

        before { anime.update status: :anons }

        it 'does not generate more news topics' do
          expect(anime.anons_news_topics).to eq [en_news_topic, ru_news_topic]
        end
      end

      context 'status changed' do
        context 'to anons (anime just created)' do
          let!(:anime) { create :anime, :with_callbacks, status: :anons }

          it 'generates 2 anons news topics' do
            expect(anime.anons_news_topics).to have(2).items
          end
        end

        context 'from anons to ongoing' do
          let(:anime) { create :anime, :with_callbacks, status: :anons }
          before { anime.update status: :ongoing }

          it 'generates 2 ongoing news topics' do
            expect(anime.ongoing_news_topics).to have(2).items
          end
        end
      end

      context 'status rollbacked' do
        context 'from ongoing back to anons' do
          let(:anime) do
            create :anime, :with_callbacks,
              status: :anons,
              aired_on: Time.zone.tomorrow
          end
          before { anime.update status: :ongoing }

          it 'does not change status and does not generate news topics' do
            expect(anime.status).to be_anons
            expect(anime.ongoing_news_topics).to be_empty
          end
        end

        context 'from released back to ongoing' do
          let(:anime) do
            create :anime, :with_callbacks,
              status: :ongoing,
              released_on: Time.zone.tomorrow
          end
          before { anime.update status: :released }

          it 'does not change status and does not generate news topics' do
            expect(anime.status).to be_ongoing
            expect(anime.released_news_topics).to be_empty
          end
        end
      end

      context 'number of aired episodes changed' do
        context 'first episodes aired' do
          let(:anime) { create :anime, :with_callbacks, status: :anons, episodes: 5 }
          before { anime.update episodes_aired: 1 }

          it 'changes status to ongoing and generates 2 ongoing news topics' do
            expect(anime.status).to be_ongoing
            expect(anime.ongoing_news_topics).to have(2).items
          end
        end

        context 'final episodes aired' do
          let(:anime) { create :anime, :with_callbacks, status: :ongoing, episodes: 5 }
          before { anime.update episodes_aired: 5 }

          it 'changes status to released and generates 2 released news topics' do
            expect(anime.status).to be_released
            expect(anime.released_news_topics).to have(2).items
          end
        end
      end
    end
  end

  describe 'instance methods' do
    describe '#genres' do
      let(:genre) { create :genre, :anime }
      let(:anime) { build :anime, genre_ids: [genre.id] }

      it { expect(anime.genres).to eq [genre] }
    end

    describe '#studios' do
      let(:studio) { create :studio }
      let(:anime) { build :anime, studio_ids: [studio.id] }

      it { expect(anime.studios).to eq [studio] }
    end

    # describe '#adult?' do
      # context 'by_rating' do
        # let(:anime) { build :anime, rating: rating, episodes: episodes, kind: kind }
        # let(:episodes) { 1 }
        # let(:kind) { :ova }

        # context 'G - All Ages' do
          # let(:rating) { :g }
          # it { expect(anime).to_not be_adult }
        # end

        # context 'R+ - Mild Nudity' do
          # let(:rating) { :r_plus }

          # context 'TV' do
            # let(:kind) { :tv }
            # it { expect(anime).to_not be_adult }
          # end

          # context 'OVA' do
            # let(:kind) { :ova }

            # context '1 episode' do
              # let(:episodes) { 1 }
              # it { expect(anime).to_not be_adult }
            # end

            # context '2 episodes' do
              # let(:episodes) { 2 }
              # it { expect(anime).to_not be_adult }
            # end

            # context '3 episodes' do
              # let(:episodes) { 3 }
              # it { expect(anime).to_not be_adult }
            # end
          # end

          # context 'Special' do
            # let(:kind) { :special }
            # it { expect(anime).to_not be_adult }
          # end
        # end
      # end

      # context 'censored' do
        # let(:anime) { build :anime, censored: censored }

        # context 'false' do
          # let(:censored) { false }
          # it { expect(anime).to_not be_adult }
        # end

        # context 'true' do
          # let(:censored) { true }
          # it { expect(anime).to be_adult }
        # end
      # end
    # end

    describe '#broadcast_at' do
      include_context :timecop, '06-04-2016'

      let(:anime) { build :anime, state, broadcast: broadcast, aired_on: nil }
      let(:state) { :ongoing }
      let(:broadcast) { 'Thursdays at 22:00 (JST)' }

      it { expect(anime.broadcast_at).to eq Time.zone.parse('07-04-2016 16:00') }

      context 'no broadcast' do
        let(:broadcast) { '' }
        it { expect(anime.broadcast_at).to be_nil }
      end

      context 'not ongoing or anons' do
        let(:state) { :released }
        it { expect(anime.broadcast_at).to be_nil }
      end
    end
  end

  it_behaves_like :touch_related_in_db_entry, :anime
  it_behaves_like :topics_concern, :anime
  it_behaves_like :collections_concern
  it_behaves_like :versions_concern
  it_behaves_like :clubs_concern, :anime
  it_behaves_like :contests_concern
  it_behaves_like :favourites_concern
end
