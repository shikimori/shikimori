
require 'spec_helper'

describe MalDeployer do
  before { SiteParserWithCache.stub(:load_cache).and_return({:list => {}}) }

  [[AnimeMalParser, Anime], [MangaMalParser, Manga]].each do |parser_klass, klass|
    describe parser_klass do
      describe klass do
        let (:parser) {
          p = parser_klass.new
          p.stub(:save_cache)
          p
        }

        let (:entry_id) { 1 }
        let (:entry) { create klass.name.downcase.to_sym, :id => entry_id }
        let (:data) { parser.fetch_entry(entry_id) }

        it 'updates imported_at' do
          entry.imported_at.should be(nil)
          parser.deploy(entry, data)
          entry.imported_at.should_not be(nil)
        end

        it 'updates mal_scores' do
          parser.deploy(entry, data)
          entry.mal_scores.should have(10).items
        end

        it 'sets censored for hentai' do
          data[:entry][:genres] = [{:id => Genre::HentaiID}]
          entry.censored.should_not be(true)
          parser.deploy(entry, data)
          entry.censored.should be(true)
        end

        it "doesn't set censored for non-hentai" do
          entry.censored.should_not be(true)
          parser.deploy(entry, data)
          entry.censored.should_not be(true)
        end

        it "doesn't change status from Released to Ongoing" do
          entry.status = AniMangaStatus::Released
          entry.episodes_aired = entry.episodes = 10

          data[:entry][:status] = AniMangaStatus::Ongoing
          parser.deploy(entry, data)
          entry.status.should == AniMangaStatus::Released
        end if klass == Anime

        it "changes status from Released to Ongoing" do
          entry.status = AniMangaStatus::Released
          entry.episodes_aired = 9
          entry.episodes = 10

          data[:entry][:status] = AniMangaStatus::Ongoing
          parser.deploy(entry, data)
          entry.status.should == AniMangaStatus::Ongoing
        end if klass == Anime

        describe 'genres' do
          it 'linked to entry' do
            parser.deploy(entry, data)
            entry.genres.count.should be(data[:entry][:genres].size)
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
            entry.studios.should have(data[:entry][:studios].size).items
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
            entry.publishers.should have(data[:entry][:publishers].size).items
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
            klass.find(entry.id).similar.should have(data[:recommendations].size).items
          end
        end

        describe 'related' do
          it 'linked to entry' do
            parser.deploy(entry, data)
            klass.find(entry.id).related.should_not be_empty
          end
        end

        describe 'attached images' do
          it 'created and linked to entry' do
            expect {
              parser.deploy_attached_images(entry, data[:images])
            }.to change(AttachedImage, :count).by(data[:images].size)
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
