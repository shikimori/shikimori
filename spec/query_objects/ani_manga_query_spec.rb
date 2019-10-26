describe AniMangaQuery do
  describe '#fetch' do
    def fetch options = {}, user = nil
      AniMangaQuery.new(Anime, options, user).fetch.to_a
    end

    context 'kind' do
      let!(:anime_1) { create :anime, :tv, episodes: 13 }
      let!(:anime_2) { create :anime, :tv, episodes: 0, episodes_aired: 13 }
      let!(:anime_3) { create :anime, :tv, episodes: 6 }
      let!(:anime_4) { create :anime, :tv, episodes: 13 }

      let!(:anime_5) { create :anime, :tv, episodes: 17 }
      let!(:anime_6) { create :anime, :tv, episodes: 0, episodes_aired: 17 }
      let!(:anime_7) { create :anime, :tv, episodes: 26 }

      let!(:anime_8) { create :anime, :tv, episodes: 29 }
      let!(:anime_9) { create :anime, :tv, episodes: 0, episodes_aired: 100 }
      let!(:anime_10) { create :anime, :movie }

      context 'tv' do
        it do
          expect(fetch kind: 'tv').to have(9).items
          expect(fetch kind: '!tv').to have(1).item
        end
      end

      context 'tv_13' do
        it do
          expect(fetch kind: 'tv_13').to have(4).items
          expect(fetch kind: '!tv_13').to have(6).items
        end
      end

      context 'tv_24' do
        it do
          expect(fetch kind: 'tv_24').to have(3).items
          expect(fetch kind: '!tv_24').to have(7).items
        end
      end

      context 'tv_48' do
        it do
          expect(fetch kind: 'tv_48').to have(2).items
          expect(fetch kind: '!tv_48').to have(8).items
        end
      end

      context 'multiple types' do
        it 'positive' do
          expect(fetch kind: 'tv_13,tv_24').to have(7).items
        end

        it 'negative' do
          expect(fetch kind: '!tv_13,!tv_24').to have(3).items
        end

        it 'mixed' do
          expect(fetch kind: 'movie,tv_13,tv_24').to have(8).items
        end

        it 'tv + tv_13' do
          expect(fetch kind: 'tv,tv_13').to have(4).items
        end
      end
    end

    context 'censored' do
      let(:hentai) { create :genre, id: Genre::HENTAI_IDS.first }
      let(:yaoi) { create :genre, id: Genre::YAOI_IDS.first }
      let(:porn) { create :studio }

      let!(:anime_1) do
        create :anime,
          is_censored: true,
          genre_ids: [yaoi.id, hentai.id],
          studio_ids: [porn.id]
      end
      let!(:anime_2) do
        create :anime,
          is_censored: true,
          genre_ids: [yaoi.id],
          studio_ids: [porn.id]
      end
      let!(:anime_3) { create :anime }

      describe 'no censored' do
        it { expect(fetch).to have(3).items }
      end

      describe 'with censored' do
        it 'censored: true' do
          expect(fetch censored: [true, 'true'].sample).to have(1).item
        end
        it 'mylist' do
          allow_any_instance_of(AniMangaQuery).to receive :mylist!
          expect(fetch mylist: UserRate.statuses[:planned]).to have(3).items
        end
        it 'userlist' do
          expect(fetch userlist: true).to have(3).items
        end
        it 'censored' do
          expect(fetch censored: true).to have(1).items
        end
        it 'search' do
          allow_any_instance_of(AniMangaQuery).to receive :search!
          expect(fetch search: 'test').to have(3).items
        end
        it 'yaoi' do
          expect(fetch genre: Genre::YAOI_IDS.first.to_s).to have(2).items
        end
        it 'hentai' do
          expect(fetch genre: Genre::HENTAI_IDS.first.to_s).to have(1).item
        end
        # it 'publisher' do
          # fetch(publisher: '1').should have(3).items
        # end
        it 'studio' do
          expect(fetch studio: porn.to_param).to have(2).items
        end
      end
    end

    context 'music' do
      let!(:anime_1) { create :anime, :music }
      let!(:anime_2) { create :anime, :music }
      let!(:anime_3) { create :anime }

      describe 'no music' do
        it { expect(fetch).to have(1).item }
      end

      describe 'with musics' do
        it 'mylist' do
          allow_any_instance_of(AniMangaQuery).to receive :mylist!
          expect(fetch mylist: true).to have(3).items
        end

        it 'userlist' do
          expect(fetch userlist: true).to have(3).items
        end
      end
    end

    context 'genres, studios, publishers' do
      let(:shounen) { create :genre }
      let(:shoujo) { create :genre }
      let(:ghibli) { create :studio }
      let(:shaft) { create :studio }

      let!(:anime_1) do
        create :anime,
          genre_ids: [shounen.id, shoujo.id],
          studio_ids: [ghibli.id]
      end
      let!(:anime_2) do
        create :anime,
          genre_ids: [shounen.id],
          studio_ids: [ghibli.id]
      end
      let!(:anime_3) do
        create :anime,
          genre_ids: [shounen.id],
          studio_ids: [shaft.id, ghibli.id]
      end
      let!(:anime_4) { create :anime, studio_ids: [shaft.id] }
      let!(:anime_5) { create :anime, genre_ids: [shoujo.id] }

      describe 'genre' do
        it 'inclusive' do
          expect(fetch genre: shounen.to_param.to_s).to have(3).items
          expect(fetch genre: shoujo.to_param.to_s).to have(2).items
          expect(fetch genre: "#{shounen.to_param},#{shoujo.to_param}").to have(1).item
        end

        it 'exclusive' do
          expect(fetch genre: "!#{shounen.to_param}").to have(2).items
          expect(fetch genre: "!#{shoujo.to_param}").to have(3).items
          expect(fetch genre: "!#{shoujo.to_param},!#{shounen.to_param}").to have(1).item
        end

        it 'both' do
          expect(fetch genre: "#{shounen.to_param},!#{shoujo.to_param}").to have(2).items
          expect(fetch genre: "!#{shounen.to_param},#{shoujo.to_param}").to have(1).item
        end
      end

      describe 'studio' do
        it 'inclusive' do
          expect(fetch studio: ghibli.to_param).to have(3).items
          expect(fetch studio: shaft.to_param).to have(2).items
          expect(fetch studio: "#{ghibli.to_param},#{shaft.to_param}").to have(1).item
        end

        it 'exclusive' do
          expect(fetch studio: "!#{ghibli.to_param}").to have(2).items
          expect(fetch studio: "!#{shaft.to_param}").to have(3).items
          expect(fetch studio: "!#{shaft.to_param},!#{ghibli.to_param}").to have(1).item
        end

        it 'both' do
          expect(fetch studio: "#{ghibli.to_param},!#{shaft.to_param}").to have(2).items
          expect(fetch studio: "!#{ghibli.to_param},#{shaft.to_param}").to have(1).item
        end
      end

      it 'both' do
        expect(fetch studio: "!#{shaft.to_param},#{ghibli.to_param}", genre: "#{shounen.to_param},#{shoujo.to_param}").to have(1).item
      end

      describe 'publisher' do
        let(:jump) { create :publisher }

        let!(:manga1) do
          create :manga,
            publisher_ids: [jump.id],
            genre_ids: [shounen.id, shoujo.id]
        end
        let!(:manga2) do
          create :manga, publisher_ids: [jump.id], genre_ids: [shounen.id]
        end
        let!(:manga3) { create :manga }

        it 'inclusive' do
          expect(AniMangaQuery.new(Manga, publisher: jump.to_param).fetch.to_a).to have(2).items
        end

        it 'exclusive' do
          expect(AniMangaQuery.new(Manga, publisher: "!#{jump.to_param}").fetch.to_a).to have(1).item
        end

        it 'with genres' do
          expect(AniMangaQuery.new(Manga, publisher: jump.to_param, genre: "#{shounen.to_param},!#{shoujo.to_param}").fetch.to_a).to have(1).item
        end
      end
    end

    describe 'rating' do
      let!(:anime_1) { create :anime, rating: :r }
      let!(:anime_2) { create :anime, rating: :r }
      let!(:anime_3) { create :anime, rating: :g }
      let!(:anime_4) { create :anime, rating: :r_plus }

      it 'inclusive' do
        expect(fetch rating: 'r').to have(2).items
        expect(fetch rating: 'g').to have(1).item
        expect(fetch rating: 'r,g').to have(3).items
      end

      it 'exclusive' do
        expect(fetch rating: '!r').to have(2).items
        expect(fetch rating: '!g').to have(3).items
        expect(fetch rating: '!r,!g').to have(1).item
      end

      it 'both' do
        expect(fetch rating: 'r,!g').to have(2).items
        expect(fetch rating: '!r,g').to have(1).item
      end
    end

    describe 'score' do
      let!(:anime_1) { create :anime, score: 6.9 }
      let!(:anime_2) { create :anime, score: 7.0, ranked: 1 }
      let!(:anime_3) { create :anime, score: 7.1, ranked: 1 }

      it { expect(fetch score: '7').to eq [anime_3, anime_2] }
    end

    describe 'duration' do
      let!(:anime_1) { create :anime, duration: 10 }
      let!(:anime_2) { create :anime, duration: 20 }
      let!(:anime_3) { create :anime, duration: 20 }
      let!(:anime_4) { create :anime, duration: 35 }
      let!(:anime_5) { create :anime, duration: 35 }
      let!(:anime_6) { create :anime, duration: 35 }

      it 'inclusive' do
        expect(fetch duration: 'S').to have(1).item
        expect(fetch duration: 'D').to have(2).items
        expect(fetch duration: 'F').to have(3).items
        expect(fetch duration: 'S,D,F').to have(6).items
      end

      it 'exclusive' do
        expect(fetch duration: '!S').to have(5).items
        expect(fetch duration: '!D').to have(4).items
        expect(fetch duration: '!S,!F').to have(2).items
      end

      it 'both' do
        expect(fetch duration: 'S,!F').to have(1).item
        expect(fetch duration: '!S,F').to have(3).items
      end
    end

    describe 'season' do
      let!(:anime_1) { create :anime, aired_on: Date.parse('2011-02-01') }
      let!(:anime_2) { create :anime, aired_on: Date.parse('2011-02-01') }
      let!(:anime_3) { create :anime, aired_on: Date.parse('2010-02-01') }

      it 'inclusive' do
        expect(fetch season: '2011').to have(2).items
        expect(fetch season: 'winter_2011').to have(2).items
        expect(fetch season: '2010_2011').to have(3).items
        expect(fetch season: '2010,2011').to have(3).items
      end

      it 'exclusive' do
        expect(fetch season: '!2011').to have(1).item
        expect(fetch season: '!2011,!2010').to have(0).items
      end

      it 'both' do
        expect(fetch season: '!2011,2010').to have(1).item
      end
    end

    describe 'status' do
      let!(:anime_1) { create :anime, :ongoing, aired_on: Time.zone.now - 1.month }
      let!(:anime_2) { create :anime, :anons }
      let!(:anime_3) { create :anime, :anons }
      let!(:anime_4) { create :anime, :released }
      let!(:anime_5) { create :anime, :released }
      let!(:anime_6) { create :anime, :released, aired_on: 6.months.ago, released_on: 2.months.ago }

      it 'inclusive' do
        expect(fetch status: 'ongoing').to have(1).item
        expect(fetch status: 'latest').to have(1).item
        expect(fetch status: 'anons').to have(2).items
        expect(fetch status: 'released').to have(3).items
        expect(fetch status: 'ongoing,anons').to have(3).items
      end

      it 'exclusive' do
        expect(fetch status: '!ongoing').to have(5).items
        expect(fetch status: '!anons,!released').to have(1).item
      end

      it 'both' do
        expect(fetch status: '!anons,ongoing').to have(1).item
      end
    end

    describe 'franchise' do
      let!(:anime_1) { create :anime, franchise: 'qwe' }
      let!(:anime_2) { create :anime, franchise: 'zxc' }
      let!(:anime_3) { create :anime, franchise: 'zxc' }
      let!(:anime_4) { create :anime }

      it 'inclusive' do
        expect(fetch franchise: 'zxc').to eq [anime_2, anime_3]
        expect(fetch franchise: 'zxc,qwe').to eq [anime_1, anime_2, anime_3]
      end

      it 'exclusive' do
        expect(fetch franchise: '!zxc').to eq [anime_1, anime_4]
      end
    end

    describe 'achievement' do
      let(:hentai) { create :genre, id: Genre::HENTAI_IDS.first }

      let!(:anime_1) { create :anime, genre_ids: [hentai.id] }
      let!(:anime_2) { create :anime, genre_ids: [hentai.id] }
      let!(:anime_3) { create :anime }

      it { expect(fetch achievement: 'otaku').to eq [anime_1, anime_2] }
    end

    describe 'mylist' do
      let(:anime_1) { create :anime, score: 9 }
      let(:anime_2) { create :anime, score: 8 }
      let(:anime_3) { create :anime, score: 7 }

      let!(:user_rate_1) { create :user_rate, :planned, target: anime_1, user: user }
      let!(:user_rate_2) { create :user_rate, :watching, target: anime_2, user: user }
      let!(:user_rate_3) { create :user_rate, :watching, target: anime_3, user: user }

      let!(:anime_4) { create :anime }
      let!(:anime_5) { create :anime }

      it 'inclusive' do
        expect(fetch({ mylist: UserRate.statuses[:planned].to_s }, user))
          .to eq [anime_1]
        expect(fetch({ mylist: 'watching' }, user)).to eq [anime_2, anime_3]
        expect(fetch({ mylist: UserRate.statuses[:watching].to_s }, user))
          .to eq [anime_2, anime_3]
        expect(fetch({ mylist: "#{UserRate.statuses[:planned]},#{UserRate.statuses[:watching]}" }, user))
          .to eq [anime_1, anime_2, anime_3]
      end

      it 'exclusive' do
        expect(fetch({ mylist: "!#{UserRate.statuses[:planned]}" }, user)).to have(4).items
        expect(fetch({ mylist: '!planned' }, user)).to have(4).items
        expect(fetch({ mylist: "!#{UserRate.statuses[:planned]},!#{UserRate.statuses[:watching]}" }, user)).to have(2).items
      end

      it 'both' do
        expect(fetch({ mylist: "#{UserRate.statuses[:planned]},!#{UserRate.statuses[:watching]}" }, user)).to have(1).item
      end
    end

    describe 'exclude_ai_genres' do
      let!(:common_anime) { create :anime, id: 1 }
      let!(:anime_yaoi) { create :anime, id: 2, genre_ids: [yaoi.id] }
      let!(:anime_hentai) { create :anime, id: 3, genre_ids: [hentai.id] }
      let!(:anime_yuri) { create :anime, id: 4, genre_ids: [yuri.id] }
      let!(:anime_shounen_ai) { create :anime, id: 5, genre_ids: [shounen_ai.id] }
      let!(:anime_shoujo_ai) { create :anime, id: 6, genre_ids: [shoujo_ai.id] }

      let(:yaoi) { create :genre, id: Genre::YAOI_IDS.sample }
      let(:yuri) { create :genre, id: Genre::YURI_IDS.sample }
      let(:hentai) { create :genre, id: Genre::HENTAI_IDS.sample }
      let(:shounen_ai) { create :genre, id: Genre::SHOUNEN_AI_IDS.sample }
      let(:shoujo_ai) { create :genre, id: Genre::SHOUJO_AI_IDS.sample }

      let(:options) { { AniMangaQuery::EXCLUDE_AI_GENRES_KEY => true } }

      it do
        # male
        expect(fetch options, build_stubbed(:user, sex: 'male')).to eq [
          common_anime,
          anime_hentai,
          anime_yuri,
          anime_shoujo_ai
        ]

        # female
        expect(fetch options, build_stubbed(:user, sex: 'female')).to eq [
          common_anime,
          anime_yaoi,
          anime_shounen_ai
        ]

        # unknown gender
        expect(fetch options, build_stubbed(:user)).to eq [common_anime]
      end
    end

    describe 'ids' do
      let!(:anime_1) { create :anime, score: 9 }
      let!(:anime_2) { create :anime, score: 8 }
      let!(:anime_3) { create :anime, score: 7 }

      it do
        expect(fetch ids: [anime_1.id.to_s]).to eq [anime_1]
        expect(fetch ids: [anime_2.id]).to eq [anime_2]
        expect(fetch ids: [anime_2.id, anime_1.id]).to eq [anime_1, anime_2]
        expect(fetch ids: "#{anime_2.id},#{anime_1.id}").to eq [anime_1, anime_2]
      end
    end

    describe 'exclude_ids' do
      let!(:anime_1) { create :anime, score: 9 }
      let!(:anime_2) { create :anime, score: 8 }
      let!(:anime_3) { create :anime, score: 7 }

      it do
        expect(fetch exclude_ids: [anime_1.id.to_s]).to eq [anime_2, anime_3]
        expect(fetch exclude_ids: [anime_2.id]).to eq [anime_1, anime_3]
        expect(fetch exclude_ids: [anime_1.id, anime_2.id]).to eq [anime_3]
        expect(fetch exclude_ids: "#{anime_1.id},#{anime_2.id}").to eq [anime_3]
      end
    end

    describe 'order' do
      let!(:anime_1) { create :anime, ranked: 10, name: 'AAA', episodes: 10 }
      let!(:anime_2) { create :anime, ranked: 5, name: 'BBB', episodes: 20 }

      it do
        expect(fetch.first.id).to eq anime_2.id
        expect(fetch(order: 'name').first.id).to eq anime_1.id
        expect(fetch(order: 'id').first.id).to eq anime_2.id
      end

      describe 'episodes' do
        let!(:anime_3) { create :anime, ranked: 5, name: 'BBB', episodes: 0, episodes_aired: 15 }
        it { expect(fetch(order: 'position').map(&:id)).to eq [anime_2.id, anime_3.id, anime_1.id] }
      end
    end

    describe 'search' do
      let!(:anime_1) { create :anime }
      let!(:anime_2) { create :anime }

      before do
        allow(Search::Anime).to receive(:call)
          .and_return(Anime.where(id: anime_2.id))
          # .with(scope: Anime.all, phrase: phrase, ids_limit: AniMangaQuery::SEARCH_IDS_LIMIT)
      end
      let(:phrase) { 'search query' }

      it { expect(fetch search: phrase).to eq [anime_2] }
    end
  end
end
