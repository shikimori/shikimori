# TODO: refactor from "expect((...).size).to eq(...)" to expect(...).to eq [...]
describe AniMangaQuery do
  describe '#complete' do
    let!(:anime_1) { create :anime, name: 'ffff', japanese: ['kkkk', 'シュタインズ ゲート'] }
    let!(:anime_2) { create :anime, name: 'testt', synonyms: ['xxxx'] }
    let!(:anime_3) { create :anime, name: 'zula zula', russian: 'дада То' }
    let!(:anime_4) { create :anime, name: 'Test', english: ['bbbb'], japanese: ['シュタインズ ゲー'] }

    it { expect(AniMangaQuery.new(Anime, { search: 'test' }, nil).complete).to have(2).items }
    it { expect(AniMangaQuery.new(Anime, { search: 'シュタインズ' }, nil).complete).to have(2).items }
    it { expect(AniMangaQuery.new(Anime, { search: 'z z' }, nil).complete).to have(1).item }
    it { expect(AniMangaQuery.new(Anime, { search: 'fofo' }, nil).complete).to have(0).items }
    it { expect(AniMangaQuery.new(Anime, { search: 'То' }, nil).complete).to have(1).item }
  end

  describe '#fetch' do
    def fetch options={}, user=nil, page=nil, limit=nil
      AniMangaQuery.new(Anime, options, user).fetch(page, limit).to_a
    end

    context 'type' do
      let!(:anime_1) { create :anime, :tv, episodes: 13 }
      let!(:anime_2) { create :anime, :tv, episodes: 0, episodes_aired: 13 }
      let!(:anime_3) { create :anime, :tv, episodes: 6 }
      let!(:anime_4) { create :anime, :tv, episodes: 13 }

      let!(:anime_5) { create :anime, :tv, episodes: 17 }
      let!(:anime_6) { create :anime, :tv, episodes: 0, episodes_aired: 17 }
      let!(:anime_7) { create :anime, :tv, episodes: 26 }

      let!(:anime_8) { create :anime, :tv, episodes: 29 }
      let!(:anime_9) { create :anime, :tv, episodes: 0, episodes_aired: 100 }

      context 'tv' do
        before { create :anime, :movie }
        it do
          expect(fetch type: 'tv').to have(9).items
          expect(fetch type: '!tv').to have(1).item
        end
      end

      context 'tv_13' do
        it do
          expect(fetch type: 'tv_13').to have(4).items
          expect(fetch type: '!tv_13').to have(5).items
        end
      end

      context 'tv_24' do
        it do
          expect(fetch type: 'tv_24').to have(3).items
          expect(fetch type: '!tv_24').to have(6).items
        end
      end

      context 'tv_48' do
        it do
          expect(fetch type: 'tv_48').to have(2).items
          expect(fetch type: '!tv_48').to have(7).items
        end
      end

      it 'multiple negative' do
        expect(fetch type: '!tv_13,!tv_24').to have(2).items
      end
      it 'multiple positive' do
        expect(fetch type: 'tv_13,tv_24').to have(0).items
      end
    end

    context 'censored' do
      let(:hentai) { create :genre, id: Genre::HentaiID }
      let(:yaoi) { create :genre, id: Genre::YaoiID }
      let(:porn) { create :studio }

      let!(:anime_1) { create :anime, censored: true, genres: [yaoi, hentai], studios: [porn] }
      let!(:anime_2) { create :anime, censored: true, genres: [yaoi], studios: [porn] }
      let!(:anime_3) { create :anime }

      describe 'no censored'do
        it { expect(fetch).to have(1).item }
      end

      describe 'with censored' do
        it 'mylist' do
          allow_any_instance_of(AniMangaQuery).to receive :mylist!
          expect(fetch mylist: "#{UserRate.statuses[:planned]}").to have(3).items
        end
        it 'userlist' do
          expect(fetch userlist: true).to have(3).items
        end
        it 'with_censored' do
          expect(fetch with_censored: true).to have(3).items
        end
        it 'search' do
          allow_any_instance_of(AniMangaQuery).to receive :search!
          expect(fetch search: 'test').to have(3).items
        end
        it 'yaoi' do
          expect(fetch genre: "#{Genre::YaoiID}").to have(2).items
        end
        it 'hentai' do
          expect(fetch genre: "#{Genre::HentaiID}").to have(1).item
        end
        #it 'publisher' do
          #fetch(publisher: '1').should have(3).items
        #end
        it 'studio' do
          expect(fetch studio: "#{porn.to_param}").to have(2).items
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

      let!(:anime_1) { create :anime, genres: [shounen, shoujo], studios: [ghibli] }
      let!(:anime_2) { create :anime, genres: [shounen], studios: [ghibli] }
      let!(:anime_3) { create :anime, genres: [shounen], studios: [shaft, ghibli] }
      let!(:anime_4) { create :anime, studios: [shaft] }
      let!(:anime_5) { create :anime, genres: [shoujo] }

      describe 'genre' do
        it 'inclusive' do
          expect(fetch genre: "#{shounen.to_param}").to have(3).items
          expect(fetch genre: "#{shoujo.to_param}").to have(2).items
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
          expect(fetch studio: "#{ghibli.to_param}").to have(3).items
          expect(fetch studio: "#{shaft.to_param}").to have(2).items
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

        let!(:manga1) { create :manga, publishers: [jump], genres: [shounen, shoujo] }
        let!(:manga2) { create :manga, publishers: [jump], genres: [shounen] }
        let!(:manga3) { create :manga }

        it 'inclusive' do
          expect(AniMangaQuery.new(Manga, publisher: "#{jump.to_param}").fetch().to_a).to have(2).items
        end

        it 'exclusive' do
          expect(AniMangaQuery.new(Manga, publisher: "!#{jump.to_param}").fetch().to_a).to have(1).item
        end

        it 'with genres' do
          expect(AniMangaQuery.new(Manga,
            publisher: "#{jump.to_param}",
            genre: "#{shounen.to_param},!#{shoujo.to_param}"
          ).fetch().to_a).to have(1).item
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
         expect(fetch status: 'planned').to have(2).items
         expect(fetch status: 'released').to have(3).items
         expect(fetch status: 'ongoing,planned').to have(3).items
      end

      it 'exclusive' do
        expect(fetch status: '!ongoing').to have(5).items
        expect(fetch status: '!planned,!released').to have(1).item
      end

      it 'both' do
        expect(fetch status: '!planned,ongoing').to have(1).item
      end
    end

    describe 'mylist' do
      let(:user) { create :user }
      let(:anime_1) { create :anime }
      let(:anime_2) { create :anime }
      let(:anime_3) { create :anime }

      let!(:user_rate1) { create :user_rate, user_id: user.id, target_id: anime_1.id, target_type: Anime.name, status: UserRate.statuses[:planned] }
      let!(:user_rate2) { create :user_rate, user_id: user.id, target_id: anime_2.id, target_type: Anime.name, status: UserRate.statuses[:watching] }
      let!(:user_rate3) { create :user_rate, user_id: user.id, target_id: anime_3.id, target_type: Anime.name, status: UserRate.statuses[:watching] }

      let!(:anime_4) { create :anime }
      let!(:anime_5) { create :anime }

      it 'inclusive' do
        expect(fetch({mylist: "#{UserRate.statuses[:planned]}"}, user)).to have(1).item
        expect(fetch({mylist: "#{UserRate.statuses[:watching]}"}, user)).to have(2).items
        expect(fetch({mylist: "#{UserRate.statuses[:planned]},#{UserRate.statuses[:watching]}"}, user)).to have(3).items
      end

      it 'exclusive' do
        expect(fetch({mylist: "!#{UserRate.statuses[:planned]}"}, user)).to have(4).items
        expect(fetch({mylist: "!#{UserRate.statuses[:planned]},!#{UserRate.statuses[:watching]}"}, user)).to have(2).items
      end

      it 'both' do
        expect(fetch({mylist: "#{UserRate.statuses[:planned]},!#{UserRate.statuses[:watching]}"}, user)).to have(1).item
      end
    end

    describe 'exclude_ai_genres' do
      let!(:common_anime) { create :anime, id: 1 }
      let!(:anime_yaoi) { create :anime, id: 2, genres: [yaoi] }
      let!(:anime_hentai) { create :anime, id: 3, genres: [hentai] }
      let!(:anime_yuri) { create :anime, id: 4, genres: [yuri] }
      let!(:anime_shounen_ai) { create :anime, id: 5, genres: [shounen_ai] }
      let!(:anime_shoujo_ai) { create :anime, id: 6, genres: [shoujo_ai] }

      let(:yaoi) { create :genre, id: Genre::YaoiID }
      let(:yuri) { create :genre, id: Genre::YuriID }
      let(:hentai) { create :genre, id: Genre::HentaiID }
      let(:shounen_ai) { create :genre, id: Genre::ShounenAiID }
      let(:shoujo_ai) { create :genre, id: Genre::ShoujoAiID }

      let(:options) {{ exclude_ai_genres: true }}

      it do
        # male
        expect(fetch options, build_stubbed(:user, sex: 'male')).to eq(
          [common_anime, anime_hentai, anime_yuri, anime_shoujo_ai])

        # female
        expect(fetch options, build_stubbed(:user, sex: 'female')).to eq(
          [common_anime, anime_yaoi, anime_shounen_ai])

        # unknown gender
        expect(fetch options, build_stubbed(:user)).to eq([common_anime])
      end
    end

    describe 'exclude_ids' do
      let!(:anime_1) { create :anime, id: 1 }
      let!(:anime_2) { create :anime, id: 2 }
      let!(:anime_3) { create :anime, id: 3 }

      it do
        expect(fetch exclude_ids: ['1']).to have(2).items
        expect(fetch exclude_ids: [2]).to have(2).items
        expect(fetch exclude_ids: [1, 2]).to have(1).item
      end
    end

    describe 'order' do
      let!(:anime_1) { create :anime, ranked: 10, name: 'AAA', episodes: 10 }
      let!(:anime_2) { create :anime, ranked: 5, name: 'BBB', episodes: 20 }

      it do
        expect((fetch ).first.id).to eq anime_2.id
        expect((fetch order: 'name').first.id).to eq anime_1.id
        expect((fetch order: 'id').first.id).to eq anime_2.id
      end

      describe 'episodes' do
        let!(:anime_3) { create :anime, ranked: 5, name: 'BBB', episodes: 0, episodes_aired: 15 }
        it { expect(fetch(order: 'position').map(&:id)).to eq [anime_2.id, anime_3.id, anime_1.id] }
      end
    end

    describe 'search' do
      before do
        create :anime, name: 'ffff', japanese: ['kkkk', 'シュタインズ ゲート'], ranked: 1
        @ranked = create :anime, name: 'testt', synonyms: ['xxxx'], ranked: 2
        create :anime, name: 'zula zula', russian: 'дада', ranked: 3
        @exact = create :anime, name: 'test', english: ['bbbb'], japanese: ['シュタインズ ゲー'], ranked: 4
      end

      it 'abbreviations match' do
        expect(fetch search: 'zz').to have(1).item
      end
      it 'partial match' do
        expect(fetch search: 'test').to have(2).items
      end
      it 'correct sort order in partial search' do
        expect(fetch(search: 'test').first).to eq @exact
      end
      it 'correct sort order with order param' do
        expect(fetch(search: 'test', order: 'ranked').first).to eq @ranked
      end
      it 'full match' do
        expect(fetch search: 'testt').to have(1).item
      end
      it 'two words' do
        expect(fetch search: 'zz').to have(1).item
      end
      it 'two split words' do
        expect(fetch search: 'zu zu').to have(1).item
      end
      it 'broken translit' do
        expect(fetch search: 'ягдф ягдф').to have(1).item
      end
      it 'broken translit split words' do
        expect(fetch search: 'яг яг').to have(1).item
      end
      it 'russian' do
        expect(fetch search: 'да').to have(1).item
      end
      it 'synonyms' do
        expect(fetch search: 'xxx').to have(1).item
      end
      it 'english' do
        expect(fetch search: 'bbbb').to have(1).item
      end
      it 'japanese' do
        expect(fetch search: 'シュタインズ').to have(2).items
      end
      it 'star mark english' do
        expect(fetch search: 'z*la').to have(1).item
      end
      it 'star mark japanese' do
        expect(fetch search: 'シュ*ンズ*ート').to have(1).item
      end
    end

    describe 'paginated' do
      let!(:anime_1) { create :anime, :tv, episodes: 13 }
      let!(:anime_2) { create :anime, :tv, episodes: 0, episodes_aired: 13 }

      it 'first page' do
        expect(fetch({}, nil, 1, 1)).to eq [anime_1, anime_2]
      end

      it 'second page' do
        expect(fetch({}, nil, 2, 1)).to eq [anime_2]
      end
    end

    describe 'with_video' do
      let!(:anime_1) { create :anime, :with_video, :tv }
      let!(:anime_2) { create :anime, :tv }
      let!(:anime_3) { create :anime, :tv }
      let!(:anime_adult) { create :anime, :with_video, :tv, rating: Anime::ADULT_RATING }

      it do
        expect(fetch with_video: true).to eq [anime_1]
        expect(fetch with_video: true, is_adult: true).to eq [anime_adult]
      end
    end
  end
end
