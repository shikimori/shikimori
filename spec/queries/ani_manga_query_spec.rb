# TODO: refactor from "expect((...).size).to eq(...)" to expect(...).to eq [...]
describe AniMangaQuery do
  describe '#complete' do
    let!(:anime_1) { create :anime, name: 'ffff', japanese: ['kkkk', 'シュタインズ ゲート'] }
    let!(:anime_2) { create :anime, name: 'testt', synonyms: ['xxxx'] }
    let!(:anime_3) { create :anime, name: 'zula zula', russian: 'дада То' }
    let!(:anime_4) { create :anime, name: 'Test', english: ['bbbb'], japanese: ['シュタインズ ゲー'] }

    it { expect(AniMangaQuery.new(Anime, { search: 'test' }, nil).complete.size).to eq(2) }
    it { expect(AniMangaQuery.new(Anime, { search: 'シュタインズ' }, nil).complete.size).to eq(2) }
    it { expect(AniMangaQuery.new(Anime, { search: 'z z' }, nil).complete.size).to eq(1) }
    it { expect(AniMangaQuery.new(Anime, { search: 'fofo' }, nil).complete.size).to eq(0) }
    it { expect(AniMangaQuery.new(Anime, { search: 'То' }, nil).complete.size).to eq(1) }
  end

  describe '#fetch' do
    def fetch options={}, user=nil, page=nil, limit=nil
      AniMangaQuery.new(Anime, options, user).fetch(page, limit).to_a
    end

    context 'type' do
      let!(:anime_1) { create :anime, kind: 'TV', episodes: 13 }
      let!(:anime_2) { create :anime, kind: 'TV', episodes: 0, episodes_aired: 13 }
      let!(:anime_3) { create :anime, kind: 'TV', episodes: 6 }
      let!(:anime_4) { create :anime, kind: 'TV', episodes: 13 }

      let!(:anime_5) { create :anime, kind: 'TV', episodes: 17 }
      let!(:anime_6) { create :anime, kind: 'TV', episodes: 0, episodes_aired: 17 }
      let!(:anime_7) { create :anime, kind: 'TV', episodes: 26 }

      let!(:anime_8) { create :anime, kind: 'TV', episodes: 29 }
      let!(:anime_9) { create :anime, kind: 'TV', episodes: 0, episodes_aired: 100 }

      context 'TV' do
        before { create :anime, kind: 'Movie' }
        it do
          expect(fetch(type: 'TV').size).to eq(9)
          expect(fetch(type: '!TV').size).to eq(1)
        end
      end

      context 'TV-13' do
        it do
          expect(fetch(type: 'TV-13').size).to eq(4)
          expect(fetch(type: '!TV-13').size).to eq(5)
        end
      end

      context 'TV-24' do
        it do
          expect(fetch(type: 'TV-24').size).to eq(3)
          expect(fetch(type: '!TV-24').size).to eq(6)
        end
      end

      context 'TV-48' do
        it do
          expect(fetch(type: 'TV-48').size).to eq(2)
          expect(fetch(type: '!TV-48').size).to eq(7)
        end
      end

      it 'multiple negative' do
        expect(fetch(type: '!TV-13,!TV-24').size).to eq(2)
      end
      it 'multiple positive' do
        expect(fetch(type: 'TV-13,TV-24').size).to eq(0)
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
        it { expect(fetch.size).to eq(1) }
      end

      describe 'with censored' do
        it 'mylist' do
          allow_any_instance_of(AniMangaQuery).to receive :mylist!
          expect(fetch(mylist: "#{UserRate.statuses[:planned]}").size).to eq(3)
        end
        it 'userlist' do
          expect(fetch(userlist: true).size).to eq(3)
        end
        it 'with_censored' do
          expect(fetch(with_censored: true).size).to eq(3)
        end
        it 'search' do
          allow_any_instance_of(AniMangaQuery).to receive :search!
          expect(fetch(search: 'test').size).to eq(3)
        end
        it 'yaoi' do
          expect(fetch(genre: "#{Genre::YaoiID}").to_a.size).to eq(2)
        end
        it 'hentai' do
          expect(fetch(genre: "#{Genre::HentaiID}").to_a.size).to eq(1)
        end
        #it 'publisher' do
          #fetch(publisher: '1').should have(3).items
        #end
        it 'studio' do
          expect(fetch(studio: "#{porn.to_param}").to_a.size).to eq(2)
        end
      end
    end

    context 'music' do
      let!(:anime_1) { create :anime, kind: 'Music' }
      let!(:anime_2) { create :anime, kind: 'Music' }
      let!(:anime_3) { create :anime }

      describe 'no music' do
        it { expect(fetch.size).to eq(1) }
      end

      describe 'with musics' do
        it 'mylist' do
          allow_any_instance_of(AniMangaQuery).to receive :mylist!
          expect(fetch(mylist: true).size).to eq(3)
        end

        it 'userlist' do
          expect(fetch(userlist: true).size).to eq(3)
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
          expect(fetch(genre: "#{shounen.to_param}").to_a.size).to eq(3)
          expect(fetch(genre: "#{shoujo.to_param}").to_a.size).to eq(2)
          expect(fetch(genre: "#{shounen.to_param},#{shoujo.to_param}").to_a.size).to eq(1)
        end

        it 'exclusive' do
          expect(fetch(genre: "!#{shounen.to_param}").to_a.size).to eq(2)
          expect(fetch(genre: "!#{shoujo.to_param}").to_a.size).to eq(3)
          expect(fetch(genre: "!#{shoujo.to_param},!#{shounen.to_param}").to_a.size).to eq(1)
        end

        it 'both' do
          expect(fetch(genre: "#{shounen.to_param},!#{shoujo.to_param}").to_a.size).to eq(2)
          expect(fetch(genre: "!#{shounen.to_param},#{shoujo.to_param}").to_a.size).to eq(1)
        end
      end

      describe 'studio' do
        it 'inclusive' do
          expect(fetch(studio: "#{ghibli.to_param}").to_a.size).to eq(3)
          expect(fetch(studio: "#{shaft.to_param}").to_a.size).to eq(2)
          expect(fetch(studio: "#{ghibli.to_param},#{shaft.to_param}").to_a.size).to eq(1)
        end

        it 'exclusive' do
          expect(fetch(studio: "!#{ghibli.to_param}").to_a.size).to eq(2)
          expect(fetch(studio: "!#{shaft.to_param}").to_a.size).to eq(3)
          expect(fetch(studio: "!#{shaft.to_param},!#{ghibli.to_param}").to_a.size).to eq(1)
        end

        it 'both' do
          expect(fetch(studio: "#{ghibli.to_param},!#{shaft.to_param}").to_a.size).to eq(2)
          expect(fetch(studio: "!#{ghibli.to_param},#{shaft.to_param}").to_a.size).to eq(1)
        end
      end

      it 'both' do
        expect(fetch(studio: "!#{shaft.to_param},#{ghibli.to_param}", genre: "#{shounen.to_param},#{shoujo.to_param}").to_a.size).to eq(1)
      end

      describe 'publisher' do
        let(:jump) { create :publisher }

        let!(:manga1) { create :manga, publishers: [jump], genres: [shounen, shoujo] }
        let!(:manga2) { create :manga, publishers: [jump], genres: [shounen] }
        let!(:manga3) { create :manga }

        it 'inclusive' do
          expect(AniMangaQuery.new(Manga, publisher: "#{jump.to_param}").fetch().to_a.size).to eq(2)
        end

        it 'exclusive' do
          expect(AniMangaQuery.new(Manga, publisher: "!#{jump.to_param}").fetch().to_a.size).to eq(1)
        end

        it 'with genres' do
          expect(AniMangaQuery.new(Manga,
            publisher: "#{jump.to_param}",
            genre: "#{shounen.to_param},!#{shoujo.to_param}"
          ).fetch().to_a.size).to eq(1)
        end
      end
    end

    describe 'rating' do
      let!(:anime_1) { create :anime, rating: AniMangaQuery::Ratings['NC-17'][0] }
      let!(:anime_2) { create :anime, rating: AniMangaQuery::Ratings['NC-17'][1] }
      let!(:anime_3) { create :anime, rating: AniMangaQuery::Ratings['G'][0] }
      let!(:anime_4) { create :anime, rating: AniMangaQuery::Ratings['R'][0] }

      it 'inclusive' do
        expect(fetch(rating: 'NC-17').size).to eq(2)
        expect(fetch(rating: 'G').size).to eq(1)
        expect(fetch(rating: 'NC-17,G').size).to eq(3)
      end

      it 'exclusive' do
        expect(fetch(rating: '!NC-17').size).to eq(2)
        expect(fetch(rating: '!G').size).to eq(3)
        expect(fetch(rating: '!NC-17,!G').size).to eq(1)
      end

      it 'both' do
        expect(fetch(rating: 'NC-17,!G').size).to eq(2)
        expect(fetch(rating: '!NC-17,G').size).to eq(1)
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
        expect(fetch(duration: 'S').size).to eq(1)
        expect(fetch(duration: 'D').size).to eq(2)
        expect(fetch(duration: 'F').size).to eq(3)
        expect(fetch(duration: 'S,D,F').size).to eq(6)
      end

      it 'exclusive' do
        expect(fetch(duration: '!S').size).to eq(5)
        expect(fetch(duration: '!D').size).to eq(4)
        expect(fetch(duration: '!S,!F').size).to eq(2)
      end

      it 'both' do
        expect(fetch(duration: 'S,!F').size).to eq(1)
        expect(fetch(duration: '!S,F').size).to eq(3)
      end
    end

    describe 'season' do
      let!(:anime_1) { create :anime, aired_on: Date.parse('2011-02-01') }
      let!(:anime_2) { create :anime, aired_on: Date.parse('2011-02-01') }
      let!(:anime_3) { create :anime, aired_on: Date.parse('2010-02-01') }

      it 'inclusive' do
        expect(fetch(season: '2011').size).to eq(2)
        expect(fetch(season: 'winter_2011').size).to eq(2)
        expect(fetch(season: '2010_2011').size).to eq(3)
        expect(fetch(season: '2010,2011').size).to eq(3)
      end

      it 'exclusive' do
        expect(fetch(season: '!2011').size).to eq(1)
        expect(fetch(season: '!2011,!2010').size).to eq(0)
      end

      it 'both' do
        expect(fetch(season: '!2011,2010').size).to eq(1)
      end
    end

    describe 'status' do
      let!(:anime_1) { create :anime, status: AniMangaStatus::Ongoing, aired_on: Time.zone.now - 1.month }
      let!(:anime_2) { create :anime, status: AniMangaStatus::Anons }
      let!(:anime_3) { create :anime, status: AniMangaStatus::Anons }
      let!(:anime_4) { create :anime, status: AniMangaStatus::Released }
      let!(:anime_5) { create :anime, status: AniMangaStatus::Released }
      let!(:anime_6) { create :anime, status: AniMangaStatus::Released, aired_on: 6.months.ago, released_on: 2.months.ago }

      it 'inclusive' do
         expect(fetch(status: 'ongoing').size).to eq(1)
         expect(fetch(status: 'planned').size).to eq(2)
         expect(fetch(status: 'released').size).to eq(3)
         expect(fetch(status: 'ongoing,planned').size).to eq(3)
         expect(fetch(status: 'latest').size).to eq(1)
      end

      it 'exclusive' do
        expect(fetch(status: '!ongoing').size).to eq(5)
        expect(fetch(status: '!planned,!released').size).to eq(1)
      end

      it 'both' do
        expect(fetch(status: '!planned,ongoing').size).to eq(1)
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
        expect(fetch({mylist: "#{UserRate.statuses[:planned]}"}, user).size).to eq(1)
        expect(fetch({mylist: "#{UserRate.statuses[:watching]}"}, user).size).to eq(2)
        expect(fetch({mylist: "#{UserRate.statuses[:planned]},#{UserRate.statuses[:watching]}"}, user).size).to eq(3)
      end

      it 'exclusive' do
        expect(fetch({mylist: "!#{UserRate.statuses[:planned]}"}, user).size).to eq(4)
        expect(fetch({mylist: "!#{UserRate.statuses[:planned]},!#{UserRate.statuses[:watching]}"}, user).size).to eq(2)
      end

      it 'both' do
        expect(fetch({mylist: "#{UserRate.statuses[:planned]},!#{UserRate.statuses[:watching]}"}, user).size).to eq(1)
      end
    end

    describe 'exclude_ids' do
      let!(:anime_1) { create :anime, id: 1 }
      let!(:anime_2) { create :anime, id: 2 }
      let!(:anime_3) { create :anime, id: 3 }

      it do
        expect(fetch(exclude_ids: ['1']).size).to eq(2)
        expect(fetch(exclude_ids: [2]).size).to eq(2)
        expect(fetch(exclude_ids: [1, 2]).size).to eq(1)
      end
    end

    describe 'order' do
      let!(:anime_1) { create :anime, ranked: 10, name: 'AAA', episodes: 10 }
      let!(:anime_2) { create :anime, ranked: 5, name: 'BBB', episodes: 20 }

      it do
        expect(fetch().first.id).to eq anime_2.id
        expect(fetch(order: 'name').first.id).to eq anime_1.id
        expect(fetch(order: 'id').first.id).to eq anime_2.id
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
        expect(fetch(search: 'zz').size).to eq(1)
      end
      it 'partial match' do
        expect(fetch(search: 'test').size).to eq(2)
      end
      it 'correct sort order in partial search' do
        expect(fetch(search: 'test')[0]).to eq @exact
      end
      it 'correct sort order with order param' do
        expect(fetch(search: 'test', order: 'ranked')[0]).to eq @ranked
      end
      it 'full match' do
        expect(fetch(search: 'testt').size).to eq(1)
      end
      it 'two words' do
        expect(fetch(search: 'zz').size).to eq(1)
      end
      it 'two split words' do
        expect(fetch(search: 'zu zu').size).to eq(1)
      end
      it 'broken translit' do
        expect(fetch(search: 'ягдф ягдф').size).to eq(1)
      end
      it 'broken translit split words' do
        expect(fetch(search: 'яг яг').size).to eq(1)
      end
      it 'russian' do
        expect(fetch(search: 'да').size).to eq(1)
      end
      it 'synonyms' do
        expect(fetch(search: 'xxx').size).to eq(1)
      end
      it 'english' do
        expect(fetch(search: 'bbbb').size).to eq(1)
      end
      it 'japanese' do
        expect(fetch(search: 'シュタインズ').size).to eq(2)
      end
      it 'star mark english' do
        expect(fetch(search: 'z*la').size).to eq(1)
      end
      it 'star mark japanese' do
        expect(fetch(search: 'シュ*ンズ*ート').size).to eq(1)
      end
    end

    describe 'paginated' do
      let!(:anime_1) { create :anime, kind: 'TV', episodes: 13 }
      let!(:anime_2) { create :anime, kind: 'TV', episodes: 0, episodes_aired: 13 }

      it 'first page' do
        expect(fetch({}, nil, 1, 1)).to eq [anime_1, anime_2]
      end

      it 'second page' do
        expect(fetch({}, nil, 2, 1)).to eq [anime_2]
      end
    end

    describe 'with_video' do
      let!(:anime_1) { create :anime, :with_video, kind: 'TV' }
      let!(:anime_2) { create :anime, kind: 'TV' }
      let!(:anime_3) { create :anime, kind: 'TV' }
      let!(:anime_adult) { create :anime, :with_video, kind: 'TV', rating: Anime::ADULT_RATINGS.first }

      it do
        expect(fetch with_video: true).to eq [anime_1]
        expect(fetch with_video: true, is_adult: true).to eq [anime_adult]
      end
    end
  end
end
