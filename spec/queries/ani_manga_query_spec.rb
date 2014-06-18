require 'spec_helper'

describe AniMangaQuery do
  describe '#complete' do
    let!(:anime_1) { create :anime, name: 'ffff', japanese: ['kkkk', 'シュタインズ ゲート'] }
    let!(:anime_2) { create :anime, name: 'testt', synonyms: ['xxxx'] }
    let!(:anime_3) { create :anime, name: 'zula zula', russian: 'дада' }
    let!(:anime_4) { create :anime, name: 'test', english: ['bbbb'], japanese: ['シュタインズ ゲー'] }

    it { AniMangaQuery.new(Anime, { search: 'test' }, nil).complete.should have(2).items }
    it { AniMangaQuery.new(Anime, { search: 'シュタインズ' }, nil).complete.should have(2).items }
    it { AniMangaQuery.new(Anime, { search: 'z z' }, nil).complete.should have(1).item }
    it { AniMangaQuery.new(Anime, { search: 'fofo' }, nil).complete.should have(0).items }
  end

  describe '#fetch' do
    def fetch options={}, user=nil, page=nil, limit=nil
      AniMangaQuery.new(Anime, options, user).fetch(page, limit).to_a
    end

    context :type do
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
        it { fetch(type: 'TV').should have(9).items }
        it { fetch(type: '!TV').should have(1).item }
      end

      context 'TV-13' do
        it { fetch(type: 'TV-13').should have(4).items }
        it { fetch(type: '!TV-13').should have(5).items }
      end

      context 'TV-24' do
        it { fetch(type: 'TV-24').should have(3).items }
        it { fetch(type: '!TV-24').should have(6).items }
      end

      context 'TV-48' do
        it { fetch(type: 'TV-48').should have(2).items }
        it { fetch(type: '!TV-48').should have(7).items }
      end

      it 'multiple negative' do
        fetch(type: '!TV-13,!TV-24').should have(2).items
      end
      it 'multiple positive' do
        fetch(type: 'TV-13,TV-24').should have(0).items
      end
    end

    context :censored do
      let(:hentai) { create :genre, id: Genre::HentaiID }
      let(:yaoi) { create :genre, id: Genre::YaoiID }
      let(:porn) { create :studio }

      let!(:anime_1) { create :anime, censored: true, genres: [yaoi, hentai], studios: [porn] }
      let!(:anime_2) { create :anime, censored: true, genres: [yaoi], studios: [porn] }
      let!(:anime_3) { create :anime }

      describe 'no censored'do
        it { fetch.should have(1).item }
      end

      describe 'with censored' do
        it 'mylist' do
          AniMangaQuery.any_instance.stub :mylist!
          fetch(mylist: "#{UserRate.statuses[:planned]}").should have(3).items
        end
        it 'userlist' do
          fetch(controller: 'user_lists').should have(3).items
        end
        it 'with_censored' do
          fetch(with_censored: true).should have(3).items
        end
        it 'search' do
          AniMangaQuery.any_instance.stub :search!
          fetch(search: 'test').should have(3).items
        end
        it 'yaoi' do
          fetch(genre: "#{Genre::YaoiID}").to_a.should have(2).items
        end
        it 'hentai' do
          fetch(genre: "#{Genre::HentaiID}").to_a.should have(1).items
        end
        #it 'publisher' do
          #fetch(publisher: '1').should have(3).items
        #end
        it 'studio' do
          fetch(studio: "#{porn.to_param}").to_a.should have(2).items
        end
      end
    end

    context :music do
      let!(:anime_1) { create :anime, kind: 'Music' }
      let!(:anime_2) { create :anime, kind: 'Music' }
      let!(:anime_3) { create :anime }

      describe 'no music' do
        it { fetch.should have(1).item }
      end

      describe 'with musics' do
        it 'mylist' do
          AniMangaQuery.any_instance.stub :mylist!
          fetch(mylist: true).should have(3).items
        end

        it 'userlist' do
          fetch(controller: 'user_lists').should have(3).items
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
        describe 'inclusive' do
          it { fetch(genre: "#{shounen.to_param}").to_a.should have(3).items }
          it { fetch(genre: "#{shoujo.to_param}").to_a.should have(2).items }
          it { fetch(genre: "#{shounen.to_param},#{shoujo.to_param}").to_a.should have(1).item }
        end

        describe 'exclusive' do
          it { fetch(genre: "!#{shounen.to_param}").to_a.should have(2).items }
          it { fetch(genre: "!#{shoujo.to_param}").to_a.should have(3).items }
          it { fetch(genre: "!#{shoujo.to_param},!#{shounen.to_param}").to_a.should have(1).item }
        end

        describe 'both' do
          it { fetch(genre: "#{shounen.to_param},!#{shoujo.to_param}").to_a.should have(2).items }
          it { fetch(genre: "!#{shounen.to_param},#{shoujo.to_param}").to_a.should have(1).item }
        end
      end

      describe 'studio' do
        describe 'inclusive' do
          it { fetch(studio: "#{ghibli.to_param}").to_a.should have(3).items }
          it { fetch(studio: "#{shaft.to_param}").to_a.should have(2).items }
          it { fetch(studio: "#{ghibli.to_param},#{shaft.to_param}").to_a.should have(1).item }
        end

        describe 'exclusive' do
          it { fetch(studio: "!#{ghibli.to_param}").to_a.should have(2).items }
          it { fetch(studio: "!#{shaft.to_param}").to_a.should have(3).items }
          it { fetch(studio: "!#{shaft.to_param},!#{ghibli.to_param}").to_a.should have(1).item }
        end

        describe 'both' do
          it { fetch(studio: "#{ghibli.to_param},!#{shaft.to_param}").to_a.should have(2).items }
          it { fetch(studio: "!#{ghibli.to_param},#{shaft.to_param}").to_a.should have(1).item }
        end
      end

      describe 'both' do
        it { fetch(studio: "!#{shaft.to_param},#{ghibli.to_param}", genre: "#{shounen.to_param},#{shoujo.to_param}").to_a.should have(1).item }
      end

      describe 'publisher' do
        let(:jump) { create :publisher }

        let!(:manga1) { create :manga, publishers: [jump], genres: [shounen, shoujo] }
        let!(:manga2) { create :manga, publishers: [jump], genres: [shounen] }
        let!(:manga3) { create :manga }

        it 'inclusive' do
          AniMangaQuery.new(Manga, publisher: "#{jump.to_param}").fetch().to_a.should have(2).items
        end

        it 'exclusive' do
          AniMangaQuery.new(Manga, publisher: "!#{jump.to_param}").fetch().to_a.should have(1).item
        end

        it 'with genres' do
          AniMangaQuery.new(Manga,
              publisher: "#{jump.to_param}",
              genre: "#{shounen.to_param},!#{shoujo.to_param}"
            ).fetch().to_a.should have(1).item
        end
      end
    end

    describe :rating do
      let!(:anime_1) { create :anime, rating: AniMangaQuery::Ratings['NC-17'][0] }
      let!(:anime_2) { create :anime, rating: AniMangaQuery::Ratings['NC-17'][1] }
      let!(:anime_3) { create :anime, rating: AniMangaQuery::Ratings['G'][0] }
      let!(:anime_4) { create :anime, rating: AniMangaQuery::Ratings['R'][0] }

      describe 'inclusive' do
        it { fetch(rating: 'NC-17').should have(2).items }
        it { fetch(rating: 'G').should have(1).item }
        it { fetch(rating: 'NC-17,G').should have(3).items }
      end

      describe 'exclusive' do
        it { fetch(rating: '!NC-17').should have(2).items }
        it { fetch(rating: '!G').should have(3).items }
        it { fetch(rating: '!NC-17,!G').should have(1).items }
      end

      describe 'both' do
        it { fetch(rating: 'NC-17,!G').should have(2).items }
        it { fetch(rating: '!NC-17,G').should have(1).item }
      end
    end

    describe :duration do
      let!(:anime_1) { create :anime, duration: 10 }
      let!(:anime_2) { create :anime, duration: 20 }
      let!(:anime_3) { create :anime, duration: 20 }
      let!(:anime_4) { create :anime, duration: 35 }
      let!(:anime_5) { create :anime, duration: 35 }
      let!(:anime_6) { create :anime, duration: 35 }

      describe 'inclusive' do
        it { fetch(duration: 'S').should have(1).item }
        it { fetch(duration: 'D').should have(2).items }
        it { fetch(duration: 'F').should have(3).items }
        it { fetch(duration: 'S,D,F').should have(6).items }
      end

      describe 'exclusive' do
        it { fetch(duration: '!S').should have(5).items }
        it { fetch(duration: '!D').should have(4).items }
        it { fetch(duration: '!S,!F').should have(2).items }
      end

      describe 'both' do
        it { fetch(duration: 'S,!F').should have(1).item }
        it { fetch(duration: '!S,F').should have(3).items }
      end
    end

    describe :season do
      let!(:anime_1) { create :anime, aired_on: Date.parse('2011-02-01') }
      let!(:anime_2) { create :anime, aired_on: Date.parse('2011-02-01') }
      let!(:anime_3) { create :anime, aired_on: Date.parse('2010-02-01') }

      describe 'inclusive' do
        it { fetch(season: '2011').should have(2).items }
        it { fetch(season: 'winter_2011').should have(2).items }
        it { fetch(season: '2010_2011').should have(3).items }
        it { fetch(season: '2010,2011').should have(3).items }
      end

      describe 'exclusive' do
        it { fetch(season: '!2011').should have(1).items }
        it { fetch(season: '!2011,!2010').should have(0).item }
      end

      describe 'both' do
        it { fetch(season: '!2011,2010').should have(1).item }
      end
    end

    describe :status do
      let!(:anime_1) { create :anime, status: AniMangaStatus::Ongoing, aired_on: DateTime.now - 1.month }
      let!(:anime_2) { create :anime, status: AniMangaStatus::Anons }
      let!(:anime_3) { create :anime, status: AniMangaStatus::Anons }
      let!(:anime_4) { create :anime, status: AniMangaStatus::Released }
      let!(:anime_5) { create :anime, status: AniMangaStatus::Released }
      let!(:anime_6) { create :anime, status: AniMangaStatus::Released }

      describe 'inclusive' do
        it { fetch(status: 'ongoing').should have(1).item }
        it { fetch(status: 'planned').should have(2).items }
        it { fetch(status: 'released').should have(3).items }
        it { fetch(status: 'ongoing,planned').should have(3).items }
      end

      describe 'exclusive' do
        it { fetch(status: '!ongoing').should have(5).items }
        it { fetch(status: '!planned,!released').should have(1).item }
      end

      describe 'both' do
        it { fetch(status: '!planned,ongoing').should have(1).item }
      end
    end

    describe :mylist do
      let(:user) { create :user }
      let(:anime_1) { create :anime }
      let(:anime_2) { create :anime }
      let(:anime_3) { create :anime }

      let!(:user_rate1) { create :user_rate, user_id: user.id, target_id: anime_1.id, target_type: Anime.name, status: UserRate.statuses[:planned] }
      let!(:user_rate2) { create :user_rate, user_id: user.id, target_id: anime_2.id, target_type: Anime.name, status: UserRate.statuses[:watching] }
      let!(:user_rate3) { create :user_rate, user_id: user.id, target_id: anime_3.id, target_type: Anime.name, status: UserRate.statuses[:watching] }

      let!(:anime_4) { create :anime }
      let!(:anime_5) { create :anime }

      describe 'inclusive' do
        it { fetch({mylist: "#{UserRate.statuses[:planned]}"}, user).should have(1).item }
        it { fetch({mylist: "#{UserRate.statuses[:watching]}"}, user).should have(2).items }
        it { fetch({mylist: "#{UserRate.statuses[:planned]},#{UserRate.statuses[:watching]}"}, user).should have(3).items }
      end

      describe 'exclusive' do
        it { fetch({mylist: "!#{UserRate.statuses[:planned]}"}, user).should have(4).items }
        it { fetch({mylist: "!#{UserRate.statuses[:planned]},!#{UserRate.statuses[:watching]}"}, user).should have(2).items }
      end

      describe 'both' do
        it { fetch({mylist: "#{UserRate.statuses[:planned]},!#{UserRate.statuses[:watching]}"}, user).should have(1).item }
      end
    end

    describe :exclude_ids do
      let!(:anime_1) { create :anime, id: 1 }
      let!(:anime_2) { create :anime, id: 2 }
      let!(:anime_3) { create :anime, id: 3 }

      it { fetch(exclude_ids: ['1']).should have(2).items }
      it { fetch(exclude_ids: [2]).should have(2).items }
      it { fetch(exclude_ids: [1, 2]).should have(1).item }
    end

    describe :order do
      let!(:anime_1) { create :anime, ranked: 10, name: 'AAA', episodes: 10 }
      let!(:anime_2) { create :anime, ranked: 5, name: 'BBB', episodes: 20 }

      it { fetch().first.id.should eq anime_2.id }
      it { fetch(order: 'name').first.id.should eq anime_1.id }
      it { fetch(order: 'id').first.id.should eq anime_2.id }

      describe :episodes do
        let!(:anime_3) { create :anime, ranked: 5, name: 'BBB', episodes: 0, episodes_aired: 15 }
        it { fetch(order: 'position').map(&:id).should eq [anime_2.id, anime_3.id, anime_1.id] }
      end
    end

    describe :search do
      before do
        create :anime, name: 'ffff', japanese: ['kkkk', 'シュタインズ ゲート'], ranked: 1
        @ranked = create :anime, name: 'testt', synonyms: ['xxxx'], ranked: 2
        create :anime, name: 'zula zula', russian: 'дада', ranked: 3
        @exact = create :anime, name: 'test', english: ['bbbb'], japanese: ['シュタインズ ゲー'], ranked: 4
      end

      it 'abbreviations match' do
        fetch(search: 'zz').should have(1).item
      end
      it 'partial match' do
        fetch(search: 'test').should have(2).items
      end
      it 'correct sort order in partial search' do
        fetch(search: 'test')[0].should eq @exact
      end
      it 'correct sort order with order param' do
        fetch(search: 'test', order: 'ranked')[0].should eq @ranked
      end
      it 'full match' do
        fetch(search: 'testt').should have(1).item
      end
      it 'two words' do
        fetch(search: 'zz').should have(1).item
      end
      it 'two split words' do
        fetch(search: 'zu zu').should have(1).item
      end
      it 'broken translit' do
        fetch(search: 'ягдф ягдф').should have(1).item
      end
      it 'broken translit split words' do
        fetch(search: 'яг яг').should have(1).item
      end
      it 'russian' do
        fetch(search: 'да').should have(1).item
      end
      it 'synonyms' do
        fetch(search: 'xxx').should have(1).item
      end
      it 'english' do
        fetch(search: 'bbbb').should have(1).item
      end
      it 'japanese' do
        fetch(search: 'シュタインズ').should have(2).items
      end
      it 'star mark english' do
        fetch(search: 'z*la').should have(1).item
      end
      it 'star mark japanese' do
        fetch(search: 'シュ*ンズ*ート').should have(1).item
      end
    end

    describe :paginated do
      let!(:anime_1) { create :anime, kind: 'TV', episodes: 13 }
      let!(:anime_2) { create :anime, kind: 'TV', episodes: 0, episodes_aired: 13 }

      it 'first page' do
        fetch({}, nil, 1, 1).should eq [anime_1, anime_2]
      end

      it 'second page' do
        fetch({}, nil, 2, 1).should eq [anime_2]
      end
    end

    describe :with_video do
      let!(:anime_1) { create :anime, kind: 'TV' }
      let!(:anime_video_1) { create :anime_video, anime: anime_1 }
      let!(:anime_2) { create :anime, kind: 'TV' }
      let!(:anime_3) { create :anime, kind: 'TV' }

      it { expect(fetch with_video: true).to have(1).item }
    end
  end
end
