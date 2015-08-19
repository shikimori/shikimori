describe Anime do
  describe 'relations' do
    it { should have_and_belong_to_many :genres }
    it { should have_and_belong_to_many :studios }

    it { should have_many :person_roles }
    it { should have_many :characters }
    it { should have_many :people }

    it { should have_many :rates }
    it { should have_many :topics }
    it { should have_many :news }

    it { should have_many :related }
    it { should have_many :related_animes }
    it { should have_many :related_mangas }

    it { should have_many :similar }
    it { should have_many :links }

    it { should have_one :thread }

    it { should have_many :user_histories }

    it { should have_many :cosplay_gallery_links }
    it { should have_many :cosplay_galleries }

    it { should have_attached_file :image }

    it { should have_many :screenshots }
    it { should have_many :all_screenshots }

    it { should have_many :videos }
    it { should have_many :all_videos }

    it { should have_many :anime_calendars }

    it { should have_many :reviews }

    it { should have_many :recommendation_ignores }

    it { should have_many :anime_videos }
    it { should have_many :episode_notifications }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in :tv, :movie, :ova, :ona, :special, :music }
    it { is_expected.to enumerize(:status).in :anons, :ongoing, :released }
    it { is_expected.to enumerize(:rating).in :none, :g, :pg, :pg_13, :r, :r_plus, :rx }
  end

  context 'hooks' do
    it { expect{create :anime, :with_thread}.to change(AniMangaComment, :count).by 1 }
  end

  #it 'should sync episodes_aired with episodes' do
    #anime = create :anime, :ongoing, episodes: 20, episodes_aired: 10
    #anime.status = :released

    #anime.episodes_aired.should_not eq(anime.episodes)

    #anime.save

    #anime.episodes_aired.should eq(anime.episodes)
  #end

  # TODO: refactor specs
  describe AnimeNews do
    describe 'created anime' do
      it 'with Ongoing status generates new AnimeNews entry' do
        expect {
          create :anime, :with_callbacks, status: :ongoing
        }.to change(AnimeNews.where(action: AnimeHistoryAction::Ongoing), :count).by 1
      end

      it 'with Anons status generates new AnimeNews entry' do
        expect {
          create :anime, :with_callbacks, status: :anons
        }.to change(AnimeNews.where(action: AnimeHistoryAction::Anons), :count).by 1
      end

      it "with Released status doesn't generate new AnimeNews entry" do
        expect {
          create :anime, :with_callbacks, status: :released
        }.to_not change(AnimeNews, :count)
      end
    end

    describe 'changed anime' do
      describe 'status' do
        it 'anons with aired_on > now() => ongoing' do
          anime = create :anime, :with_callbacks, status: :anons, aired_on: Time.zone.now + 1.week

          expect{anime.update status: :ongoing}.to_not change(AnimeNews, :count)
          expect(anime).to be_anons
        end

        it 'ongoing => anons' do
          anime = create :anime, :with_callbacks, status: :ongoing

          expect{anime.update status: :anons}.to_not change(AnimeNews, :count)
          expect(anime).to be_anons
        end

        it "should not crete news for ancient releases" do
          anime = create :anime, :with_callbacks, status: :ongoing

          expect{anime.update status: :released, released_on: Time.zone.now - 33.days}.to_not change(AnimeNews, :count)
        end

        describe 'ongoing => released' do
          let!(:anime) { create :anime, :with_callbacks, anime_params }
          let(:anime_params) {{
            status: :ongoing,
            episodes: 10,
            episodes_aired: episodes_aired,
            aired_on: 5.month.ago,
            released_on: released_on
          }}
          let(:finalize) { anime.update status: :released }

          let(:released_on) { Time.zone.tomorrow }
          let(:episodes_aired) { 9 }

          context 'released_on is present' do
            context 'one episode left' do
              context 'release is in the future' do
                let(:released_on) { Time.zone.tomorrow }

                it do
                  expect{finalize}.to_not change(AnimeNews, :count)
                  expect(anime).to be_ongoing
                end
              end

              context 'release was yesterday' do
                let(:released_on) { Time.zone.today - 1.day }

                it do
                  expect{finalize}.to change(AnimeNews, :count)
                  expect(anime).to be_released
                end
              end
            end

            context 'more than one episode left' do
              let(:episodes_aired) { 8 }

              context 'release is in the future' do
                let(:released_on) { Time.zone.tomorrow }

                it do
                  expect{finalize}.to_not change(AnimeNews, :count)
                  expect(anime).to be_ongoing
                end
              end

              context 'release is today' do
                let(:released_on) { Time.zone.today }

                it do
                  expect{finalize}.to change(AnimeNews, :count)
                  expect(anime).to be_released
                end
              end
            end
          end

          context 'released_on is absent' do
            let(:released_on) { nil }

            it do
              expect{finalize}.to change(AnimeNews, :count)
              expect(anime).to be_released
            end
          end
        end

        it 'Ongoing to Released with released_on more than 2.weeks.ago' do
          anime = create :anime, :with_callbacks, status: :ongoing

          anime.update(status: :released, released_on: Time.zone.now - 15.days)
          news = AnimeNews.last

          expect(news.processed).to be(true)
          expect(news.created_at.to_date).to eq anime.released_on
        end

        it 'Ongoing to Released to Ongoing to Released' do
          anime = create :anime, :with_callbacks, status: :ongoing
          anime.update status: :released

          expect{anime.update status: :ongoing}.to_not change(AnimeNews, :count)
          expect(anime).to be_ongoing

          expect{anime.update status: :released}.to_not change(AnimeNews, :count)
          expect(anime).to be_released
        end

        it "'' to Released" do
          anime = create :anime, status: ''
          expect {
            anime.update(status: :released, aired_on: Time.zone.now - 15.months)
          }.to_not change(AnimeNews, :count)
        end
      end

      describe 'episodes' do
        it 'Anons with episodes_aired > 0 becomes Ongoing' do
          anime = create :anime, :with_callbacks, status: :anons

          expect{anime.update episodes_aired: 1}.to change(AnimeNews.where(action: AnimeHistoryAction::Ongoing), :count).by 1
          expect(anime).to be_ongoing
        end

        it 'Ongoing with episodes_aired == episodes becomes Released' do
          anime = create :anime, :with_callbacks, status: :ongoing, episodes: 2, aired_on: Time.zone.now - 3.month

          expect{anime.update episodes_aired: 2}.to change(AnimeNews.where(action: AnimeHistoryAction::Released), :count).by 1
          expect(anime).to be_released
        end
      end
    end

    describe "reset episodes_aired" do
      let!(:anime) { create :anime, :with_callbacks, status: :ongoing, episodes: 20, episodes_aired: 10 }

      it "shouldn't generate new AnimeNews" do
        expect {
          anime.update episodes_aired: 0
        }.to_not change(AnimeNews, :count)
      end

      it "should reset anime's AnimeNews" do
        create :anime_episode_news, linked: anime
        create :anime_episode_news, linked: anime
        expect {
          anime.update episodes_aired: 0
        }.to change(AnimeNews, :count).by -2
      end
    end
  end

  describe 'adult?' do
    context 'by_rating' do
      let(:anime) { build :anime, rating: rating, episodes: episodes, kind: kind }
      let(:episodes) { 1 }
      let(:kind) { :ova }

      context 'G - All Ages' do
        let(:rating) { :g }
        it { expect(anime).to_not be_adult }
      end

      context 'R+ - Mild Nudity' do
        let(:rating) { :r_plus }

        context 'TV' do
          let(:kind) { :tv }
          it { expect(anime).to_not be_adult }
        end

        context 'OVA' do
          let(:kind) { :ova }

          context '1 episode' do
            let(:episodes) { 1 }
            it { expect(anime).to be_adult }
          end

          context '2 episodes' do
            let(:episodes) { 2 }
            it { expect(anime).to be_adult }
          end

          context '3 episodes' do
            let(:episodes) { 3 }
            it { expect(anime).to_not be_adult }
          end
        end

        context 'Special' do
          let(:kind) { :special }
          it { expect(anime).to be_adult }
        end
      end
    end

    context 'censored' do
      let(:anime) { build :anime, censored: censored }

      context 'false' do
        let(:censored) { false }
        it { expect(anime).to_not be_adult }
      end

      context 'true' do
        let(:censored) { true }
        it { expect(anime).to be_adult }
      end
    end
  end
end
