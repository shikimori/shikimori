describe AnimeVideosService, vcr: { cassette_name: 'anime_video_service' } do
  let(:video_params) {{ state: state, kind: kind, author: 'test', episode: 3, url: 'https://vk.com/video-16326869_166521208', source: 'test', anime_id: anime.id }}
  let(:user) { }

  let(:service) { AnimeVideosService.new video_params, user }

  describe '#create' do
    let(:anime) { create :anime }
    let(:state) { 'working' }
    let(:kind) { 'fandub' }

    subject(:video) { service.create }

    context 'valid video' do
      it do
        expect(video).to be_valid
        expect(video).to be_persisted

        expect(video.reports).to be_empty

        expect(video).to have_attributes video_params.except(:author, :url)
        expect(video.author.name).to eq video_params[:author]
        expect(video.url).to eq VideoExtractor::UrlExtractor.new(video_params[:url]).extract
      end

      describe 'video report' do
        let(:state) { 'uploaded' }
        subject { video.reports.first }

        context 'with user' do
          let(:user) { create :user }
          it { should have_attributes user_id: user.id, kind: 'uploaded' }
        end

        context 'without user' do
          let!(:guest) { create :user, :guest }
          it { should have_attributes user_id: User::GuestID, kind: 'uploaded' }
        end
      end
    end

    context 'invalid video' do
      let(:kind) {  }

      it { expect(video).to_not be_valid }
      it { expect(video).to_not be_persisted }
    end
  end
end
