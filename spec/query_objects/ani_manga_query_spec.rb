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
          allow_any_instance_of(Search::Anime).to receive(:call) do |instance|
            instance.send(:scope)
          end
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
  end
end
