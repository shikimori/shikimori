describe FindAnimeImporter, vcr: { cassette_name: 'find_anime_parser' } do
  let(:importer) { FindAnimeImporter.new }

  describe 'import' do
    subject(:import) { importer.import pages: pages, ids: ids, last_episodes: last_episodes }
    let!(:anime) { create :anime, name: 'xxxHOLiC: Shunmuki' }
    let(:identifier) { 'xxxholic__shunmuki' }
    let(:last_episodes) { false }
    let(:pages) { [0] }
    let(:ids) { [] }
    before { allow_any_instance_of(FindAnimeParser).to receive(:fetch_page_links).and_return [identifier] }

    describe 'video' do
      context 'no_videos' do
        let(:videos) { AnimeVideo.where anime_id: anime.id }
        it { expect{subject}.to change(videos, :count).by 8 }
      end

      context 'with_videos' do
        let(:videos) { AnimeVideo.where anime_id: anime.id }
        let!(:video) { create :anime_video, anime_id: anime.id, episode: 1, url: 'http://vk.com/video_ext.php?oid=-41880554&id=163351742&hash=f6a6a450e7aa72a9', source: 'http://findanime.ru/xxxholic__shunmuki/series1?mature=1' }
        it { expect{subject}.to change(videos, :count).by 7 }

        describe 'anime_video' do
          before { import }
          subject { anime.anime_videos.last }

          it { should be_working }
          its(:anime_id) { should eq anime.id }
          its(:url) { should eq 'http://video.sibnet.ru/shell.php?videoid=1537766' }
          its(:source) { should eq 'http://findanime.ru/xxxholic__shunmuki/series2?mature=1' }
          its(:episode) { should eq 2 }
          its(:kind) { should eq 'fandub' }
          its(:language) { should eq 'russian' }
          its(:anime_video_author_id) { should be_present }
        end
      end

      context 'same anime twice' do
        before { allow_any_instance_of(FindAnimeParser).to receive(:fetch_page_links).and_return [identifier, identifier] }
        it { expect{subject}.to change(AnimeVideo, :count).by 8 }
      end
    end

    context 'pages' do
      let(:pages) { [0] }

      describe 'imported_videos' do
        let!(:anime) { create :anime, name: 'Il Sole Penetra le Illusioni' }
        let(:identifier) { 'gen__ei_wo_kakeru_taiyou' }

        context 'last_episodes' do
          let(:last_episodes) { false }
          before do
            episode = 0
            allow_any_instance_of(FindAnimeParser).to receive(:fetch_videos) do
              episode += 1
              { episode: episode }
            end
            allow(AnimeVideo).to receive :import
            expect(importer).to receive(:build_video).exactly(14).times
          end

          it { should be_nil }
        end

        context 'partial_import' do
          let(:last_episodes) { true }
          let!(:anime_video) { create :anime_video, episode: 10, anime: anime }
          before do
            episode = 0
            allow_any_instance_of(FindAnimeParser).to receive(:fetch_videos) do
              episode += 1
              { episode: episode }
            end
            allow(AnimeVideo).to receive :import
            expect(importer).to receive(:build_video).exactly(7).times
          end

          it { should be_nil }
        end

        context 'enough videos:' do
          let!(:author_1) { create(:anime_video_author, name: '123') }

          before do
            create_list(:anime_video, FindAnimeImporter::LIMIT_RELATED_VIDEOS, anime: anime, author: author_1, episode: 1, kind: :raw)
            allow_any_instance_of(FindAnimeImporter)
              .to receive(:fetch_videos).and_return(videos)
            allow_any_instance_of(AnimeVideo)
              .to receive(:save!)
          end

          context 'flase - no video' do
            let(:video) { build(:anime_video, anime: anime) }
            let(:videos) { [video] }
            after { subject }
            it { expect_any_instance_of(AnimeVideo).to receive(:save!).once }
          end

          context 'check hosting, episode and author:' do
            let(:videos) { [build(:anime_video, anime: anime, author: author, url: url, episode: episode, kind: kind)] }
            let(:url) { 'http://video.sibnet.ru/1' }
            let(:episode) { 2 }
            let(:kind) { :fandub }
            let(:author) { create(:anime_video_author) }
            after { subject }

            context 'saved' do
              context ' - other hosting, other episode, other kind and other author' do
                it { expect_any_instance_of(AnimeVideo).to receive(:save!).once }
              end

              context ' - eq hosting, other episode, other kind and other author' do
                let(:url) { 'http://vk.com/video/other' }
                it { expect_any_instance_of(AnimeVideo).to receive(:save!).once }
              end

              context ' - other hosting, eq episode, other kind and other author' do
                let(:episode) { 1 }
                it { expect_any_instance_of(AnimeVideo).to receive(:save!).once }
              end

              context ' - other hosting, other episode, other kind and eq author' do
                let(:author) { author_1 }
                it { expect_any_instance_of(AnimeVideo).to receive(:save!).once }
              end

              context ' - eq hosting, eq episode, other kind and other author' do
                let(:url) { 'http://vk.com/video/other' }
                let(:episode) { 1 }
                it { expect_any_instance_of(AnimeVideo).to receive(:save!) }
              end

              context ' - other hosting, eq episode, other kind and eq author' do
                let(:episode) { 1 }
                let(:author) { author_1 }
                it { expect_any_instance_of(AnimeVideo).to receive(:save!) }
              end

              context ' - eq hosting, eq episode, other kind and eq author' do
                let(:url) { 'http://vk.com/video/other' }
                let(:episode) { 1 }
                let(:author) { author_1 }
                it { expect_any_instance_of(AnimeVideo).to receive(:save!) }
              end
            end

            context 'not saved' do
              context ' - eq hosting, eq episode, eq kind and eq author' do
                let(:url) { 'http://vk.com/video/other' }
                let(:episode) { 1 }
                let(:author) { author_1 }
                let(:kind) { :raw }
                it { expect_any_instance_of(AnimeVideo).to_not receive(:save!) }
              end
            end
          end
        end
      end
    end

    context 'ids' do
      let!(:anime) { create :anime, name: 'Good Morning Call' }
      let!(:anime_2) { create :anime, name: 'Dakara Boku wa, H ga Dekinai OVA' }
      let(:ids) { ['good_morning_call', 'dakara_boku_wa__h_ga_dekinai_ova'] }
      let(:pages) { [] }
      before do
        allow(AnimeVideo).to receive :import
        expect(importer).to receive(:build_video).exactly(6).times
      end
      it { should be_nil }
    end

    describe 'link' do
      context 'no_link' do
        let(:links) { AnimeLink.where service: FindAnimeImporter::SERVICE.to_s, anime_id: anime.id, identifier: identifier }
        it { expect{subject}.to change(links, :count).by 1 }
      end

      context 'with_link' do
        let!(:link) { create :anime_link, service: FindAnimeImporter::SERVICE.to_s, anime_id: anime.id, identifier: identifier }
        let(:links) { AnimeLink }
        it { expect{subject}.to_not change AnimeLink, :count }
      end
    end

    describe 'author' do
      let!(:anime) { create :anime, name: 'Dakara Boku wa, H ga Dekinai OVA' }
      let(:identifier) { 'dakara_boku_wa__h_ga_dekinai_ova' }

      context 'new_author' do
        it { expect{subject}.to change(AnimeVideoAuthor, :count).by 1 }
      end

      context 'existing_author' do
        let!(:author) { create :anime_video_author, name: 'Ancord & Nika Lenina' }
        it { expect{subject}.to_not change AnimeVideoAuthor, :count }
      end
    end

    describe 'mismatched_entries' do
      describe 'unmatched' do
        let(:identifier) { 'dakara_boku_wa__h_ga_dekinai_ova' }
        before { expect(importer).to receive(:import_videos).exactly(0).times }
        it { expect{subject}.to raise_error MismatchedEntries, "unmatched:\n#{identifier}\n" }
      end

      describe 'ambiguous' do
        let!(:anime_2) { create :anime, name: 'Триплексоголик OVA-1' }
        before { expect(importer).to receive(:import_videos).exactly(0).times }
        it { expect{subject}.to raise_error MismatchedEntries, "ambiguous:\n#{identifier} (#{anime_2.id}, #{anime.id})\n" }
      end

      describe 'twice_matched' do
        let(:identifier2) { 'kuroko_no_basket_2' }
        let!(:anime) { create :anime, name: 'xxxHOLiC: Shunmuki', russian: 'Kuroko no Basket 2' }
        before { allow_any_instance_of(FindAnimeParser).to receive(:fetch_page_links).and_return [identifier, identifier2] }
        before { expect(importer).to receive(:import_videos).exactly(0).times }

        it { expect{subject}.to raise_error MismatchedEntries, "twice matched:\n#{anime.id} (#{identifier}, #{identifier2})\n" }

        it 'does not creates links' do
          expect {
            begin
              subject
            rescue MismatchedEntries
            end
          }.to_not change(AnimeLink, :count)
        end
      end
    end

    describe 'ignores' do
      let(:identifier) { 'the_last_airbender__the_legend_of_korra_first_book_air' }
      let!(:anime) { create :anime, name: 'The Last Airbender: The Legend of Korra.First book:Air' }
      before { expect(importer).to receive(:import_videos).exactly(0).times }

      it { should be_nil }
    end

    describe 'one_episode' do
      let(:identifier) { 'aria_the_scarlet_ammo_ova' }
      let!(:anime) { create :anime, name: 'Hidan no Aria [OVA]', id: 10604 }
      before { expect(importer).to receive(:import_videos).exactly(1).times }

      it { should be_nil }
    end

    describe 'amv' do
      let(:identifier) { 'steel_fenders' }
      let!(:anime) { create :anime, name: 'Steel Fenders' }
      before do
        allow_any_instance_of(FindAnimeParser).to receive(:fetch_pages) do
          [{ videos: [{episode: 1}], categories: ['amv'], names: ['Steel Fenders'], id: 'test' }]
        end
        expect(importer).to receive(:import_videos).exactly(0).times
      end

      it { should be_nil }
    end
  end
end
