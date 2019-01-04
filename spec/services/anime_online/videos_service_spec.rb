describe AnimeOnline::VideosService do
  let(:anime) { create :anime }
  let(:service) { AnimeOnline::VideosService.new video_params }

  describe '#create' do
    let(:video_params) do
      {
        state: state,
        kind: 'fandub',
        author_name: 'test',
        episode: 3,
        url: 'https://vk.com/video-16326869_166521208',
        source: 'test',
        anime_id: anime_id
      }
    end
    let(:state) { 'working' }

    before do
      allow(VideoExtractor::PlayerUrlExtractor).to receive(:call)
        .with(video_params[:url])
        .and_return('https://vk.com/video_ext.php?oid=-16326869&id=166521208&hash=3baf626a9ce18691')
    end
    subject(:video) { service.create user }

    context 'valid video' do
      let(:anime_id) { anime.id }

      it do
        expect(video).to be_valid
        expect(video).to be_persisted

        expect(video.reports).to be_empty

        expect(video).to have_attributes video_params.except(:author_name, :url)
        expect(video.author_name).to eq video_params[:author_name]
        expect(video.url).to eq VideoExtractor::PlayerUrlExtractor.call(video_params[:url])
      end

      describe 'video report' do
        let(:state) { 'uploaded' }
        subject { video.reports.first }

        context 'with user' do
          it { is_expected.to have_attributes user_id: user.id, kind: 'uploaded' }
        end

        context 'without user' do
          let(:user) { nil }
          let!(:guest) { create :user, :guest }
          it { is_expected.to have_attributes user_id: User::GUEST_ID, kind: 'uploaded' }
        end
      end
    end

    context 'invalid video' do
      let(:anime_id) {}

      it do
        expect(video).to_not be_valid
        expect(video).to_not be_persisted
      end
    end
  end

  describe '#update' do
    let(:video_params) { { kind: kind, author_name: 'test', episode: 3 } }
    let(:anime_video) { create :anime_video }
    let(:author) { create :user, author_role }
    subject(:video) { service.update anime_video, author, nil }

    # describe 'premoderate' do
      # let(:author_role) { :user }
      # let(:video_versions) { Version.where item: anime_video }

      # context 'valid video' do
        # let(:kind) { 'subtitles' }
        # it do
          # expect { video }.to change(video_versions, :count).by 1
          # expect(video).to_not have_attributes video_params.except(:author_name)
          # expect(video_versions.first).to have_attributes(
            # state: 'pending',
            # user_id: author.id,
            # item_diff: {
              # 'kind' => ['fandub', 'subtitles'],
              # 'episode' => [1, 3],
              # 'author_name' => [nil, 'test']
            # }
          # )
        # end
      # end

      # # context 'invalid video' do
        # # let(:kind) {}
        # # it { expect { video }.to_not change Version, :count }
      # # end
    # end

    describe 'postmoderate' do
      context 'moderator' do
        let(:author_role) { :video_moderator }

        context 'valid video' do
          let(:kind) { 'subtitles' }
          it do
            expect(video).to be_valid
            expect(video).to be_persisted

            expect(video).to have_attributes video_params.except(:author_name)
            expect(video.author_name).to eq video_params[:author_name]
          end
        end

        context 'invalid video' do
          let(:kind) {}
          it { expect(video).to_not be_valid }
        end
      end

      context 'common user' do
        let(:video_versions) { Version.where item: anime_video }
        let(:author_role) { :user }
        let(:kind) { 'subtitles' }

        it do
          expect { video }.to change(video_versions, :count).by 1
          expect(video).to_not have_attributes video_params.except(:author_name)
          expect(video_versions.first).to have_attributes(
            state: 'pending',
            user_id: author.id,
            item_diff: {
              'kind' => ['fandub', 'subtitles'],
              'episode' => [1, 3],
              'author_name' => [nil, 'test']
            }
          )
        end
      end
    end
  end
end
