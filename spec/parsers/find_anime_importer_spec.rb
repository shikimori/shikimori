require 'spec_helper'

describe FindAnimeImporter do
  let(:importer) { FindAnimeImporter.new }

  describe :import do
    subject { importer.import 0, import_all }
    let!(:anime) { create :anime, name: 'xxxHOLiC: Shunmuki' }
    let(:identifier) { 'xxxholic__shunmuki' }
    let(:import_all) { true }
    before { FindAnimeParser.any_instance.stub(:fetch_page_links).and_return [identifier] }

    describe :imported_videos do
      let!(:anime) { create :anime, name: 'Il Sole Penetra le Illusioni' }
      let(:identifier) { 'gen__ei_wo_kakeru_taiyou' }

      context :full_import do
        let(:import_all) { true }
        before do
          episode = 0
          FindAnimeParser.any_instance.stub(:fetch_videos).and_return do
            episode += 1
            { episode: episode }
          end
          AnimeVideo.stub :import
          importer.should_receive(:build_video).exactly(13).times
        end

        it { should be_nil }
      end

      context :partial_import do
        let(:import_all) { false }
        let!(:anime_video) { create :anime_video, episode: 10, anime: anime }
        before do
          episode = 0
          FindAnimeParser.any_instance.stub(:fetch_videos).and_return do
            episode += 1
            { episode: episode }
          end
          AnimeVideo.stub :import
          importer.should_receive(:build_video).exactly(6).times
        end

        it { should be_nil }
      end
    end

    describe :video do
      context :no_videos do
        let(:videos) { AnimeVideo.where anime_id: anime.id }
        it { expect{subject}.to change(videos, :count).by 6 }
      end

      context :with_videos do
        let(:videos) { AnimeVideo.where anime_id: anime.id }
        let!(:video) { create :anime_video, anime_id: anime.id, episode: 1, url: 'http://vk.com/video_ext.php?oid=-41880554&id=163351742&hash=f6a6a450e7aa72a9&hd=3', source: 'http://findanime.ru/xxxholic__shunmuki/series1?mature=1' }
        it { expect{subject}.to change(videos, :count).by 5 }
      end
    end

    describe :link do
      context :no_link do
        let(:links) { AnimeLink.where service: FindAnimeImporter::SERVICE.to_s, anime_id: anime.id, identifier: identifier }
        it { expect{subject}.to change(links, :count).by 1 }
      end

      context :with_link do
        let!(:link) { create :anime_link, service: FindAnimeImporter::SERVICE.to_s, anime_id: anime.id, identifier: identifier }
        let(:links) { AnimeLink }
        it { expect{subject}.to_not change AnimeLink, :count }
      end
    end

    describe :author do
      let!(:anime) { create :anime, name: 'Dakara Boku wa, H ga Dekinai OVA' }
      let(:identifier) { 'dakara_boku_wa__h_ga_dekinai_ova' }

      context :new_author do
        it { expect{subject}.to change(AnimeVideoAuthor, :count).by 1 }
      end

      context :existing_author do
        let!(:author) { create :anime_video_author, name: 'Ancord & Nika Lenina' }
        it { expect{subject}.to_not change AnimeVideoAuthor, :count }
      end
    end

    describe :unmatched do
      let(:identifier) { 'dakara_boku_wa__h_ga_dekinai_ova' }
      it { expect{subject}.to raise_error UnmatchedEntries }
    end

    describe :ambiguous do
      let!(:anime_2) { create :anime, name: 'Триплексоголик: Весенний сон' }

      it { expect{subject}.to raise_error AmbiguousEntries }
    end
  end
end
