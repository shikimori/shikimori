describe AniMangaQuery do
  describe '#fetch' do
    def fetch options = {}, user = nil
      AniMangaQuery.new(Anime, options, user).fetch.to_a
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
