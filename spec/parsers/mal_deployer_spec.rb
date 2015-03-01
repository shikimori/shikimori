describe MalDeployer do
  before { allow(SiteParserWithCache).to receive(:load_cache).and_return(list: {}) }

  [[AnimeMalParser, Anime], [MangaMalParser, Manga]].each do |parser_klass, klass|
    describe parser_klass, vcr: { cassette_name: "#{klass.name.downcase}_mal_deployer" } do
      describe klass do
        let(:parser) {
          p = parser_klass.new
          allow(p).to receive(:save_cache)
          p
        }

        let(:entry_id) { 1 }
        let(:entry) { create klass.name.downcase.to_sym, id: entry_id }
        let(:data) { parser.fetch_entry(entry_id) }

        it 'updates imported_at' do
          expect(entry.imported_at).to be(nil)
          parser.deploy(entry, data)
          expect(entry.imported_at).not_to be(nil)
        end

        it 'updates mal_scores' do
          parser.deploy(entry, data)
          expect(entry.mal_scores.size).to eq(10)
        end

        it 'sets censored for hentai' do
          data[:entry][:genres] = [{id: Genre::HentaiID}]
          expect(entry.censored).not_to be(true)
          parser.deploy(entry, data)
          expect(entry.censored).to be(true)
        end

        it "doesn't set censored for non-hentai" do
          expect(entry.censored).not_to be(true)
          parser.deploy(entry, data)
          expect(entry.censored).not_to be(true)
        end

        it "doesn't change status from Released to Ongoing" do
          entry.status = AniMangaStatus::Released
          entry.episodes_aired = entry.episodes = 10

          data[:entry][:status] = AniMangaStatus::Ongoing
          parser.deploy(entry, data)
          expect(entry.status).to eq(AniMangaStatus::Released)
        end if klass == Anime

        it "changes status from Released to Ongoing" do
          entry.status = AniMangaStatus::Released
          entry.episodes_aired = 9
          entry.episodes = 10

          data[:entry][:status] = AniMangaStatus::Ongoing
          parser.deploy(entry, data)
          expect(entry.status).to eq(AniMangaStatus::Ongoing)
        end if klass == Anime

        describe 'genres' do
          it 'linked to entry' do
            parser.deploy(entry, data)
            expect(entry.genres.count).to be(data[:entry][:genres].size)
          end

          it 'creates only new' do
            create :genre, data[:entry][:genres].first
            expect {
              parser.deploy(entry, data)
            }.to change(Genre, :count).by(data[:entry][:genres].size - 1)
          end
        end

        describe 'studios' do
          it 'linked to entry' do
            parser.deploy(entry, data)
            expect(entry.studios.size).to eq(data[:entry][:studios].size)
          end

          it 'creates only new' do
            create :studio, data[:entry][:studios].first
            expect {
              parser.deploy(entry, data)
            }.to change(Studio, :count).by(data[:entry][:studios].size - 1)
          end
        end if klass == Anime

        describe 'publishers' do
          it 'linked to entry' do
            parser.deploy(entry, data)
            expect(entry.publishers.size).to eq(data[:entry][:publishers].size)
          end

          it 'creates only new' do
            create :publisher, data[:entry][:publishers].first
            expect {
              parser.deploy(entry, data)
            }.to change(Publisher, :count).by(data[:entry][:publishers].size - 1)
          end
        end if klass == Manga


        describe 'recommendations' do
          it 'linked to entry' do
            parser.deploy(entry, data)
            expect(klass.find(entry.id).similar.size).to eq(data[:recommendations].size)
          end
        end

        describe 'related' do
          it 'linked to entry' do
            parser.deploy(entry, data)
            expect(klass.find(entry.id).related).not_to be_empty
          end
        end

        describe 'characters' do
          it 'linked to entry' do
            expect {
              parser.deploy_characters(entry, data[:characters])
            }.to change(PersonRole, :count).by(data[:characters].size)
          end
        end

        describe 'people' do
          it 'linked to entry' do
            expect {
              parser.deploy_people(entry, data[:people])
            }.to change(PersonRole, :count).by(data[:people].size)
          end
        end
      end
    end
  end
end
