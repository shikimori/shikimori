describe Moderations::AnimeVideoReportsController do
  include_context :authenticated, :video_moderator

  let(:user_2) { create :user }
  let(:anime_video) { create :anime_video, :working, anime: create(:anime) }
  let!(:anime_video_report) do
    create :anime_video_report,
      user: user_2,
      kind: kind,
      anime_video: anime_video
  end
  let(:kind) { 'broken' }

  describe '#index' do
    before { post :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    let(:anime_video_report) { create :anime_video_report, anime_video: anime_video }
    let(:anime_video) { create :anime_video, anime: anime }
    let(:anime) { create :anime }

    describe 'html' do
      before { get :show, params: { id: anime_video_report.id } }
      it { expect(response).to have_http_status :success }
    end

    describe 'json' do
      before { get :show, params: { id: anime_video_report.id }, format: :json }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#create' do
    let(:anime_video_report) {}
    let(:params) do
      {
        kind: 'broken',
        anime_video_id: anime_video.id,
        user_id: user_2.id,
        message: 'test'
      }
    end
    before { post :create, params: { anime_video_report: params } }

    it do
      expect(response).to have_http_status :success
      expect(resource).to be_persisted
      expect(resource).to have_attributes params
    end
  end

  describe '#accept' do
    before do
      post :accept,
        params: {
          id: anime_video_report.id
        },
        format: :json
    end

    context 'broken' do
      it do
        expect(anime_video.reload.state).to eq kind
        expect(response.content_type).to eq 'application/json'
        expect(response).to have_http_status :success
      end
    end

    context 'wrong' do
      let(:kind) { 'wrong' }
      it do
        expect(anime_video.reload.state).to eq kind
        expect(response.content_type).to eq 'application/json'
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#accept_edit' do
    before do
      post :accept_edit,
        params: {
          id: anime_video_report.id
        }
    end

    it do
      expect(anime_video_report.reload).to be_accepted
      expect(anime_video.reload.state).to eq kind
      expect(response).to redirect_to edit_video_online_url(
        anime_video.anime,
        anime_video,
        host: AnimeOnlineDomain.host(anime_video.anime)
      )
    end
  end

  describe '#accept_broken' do
    before do
      post :accept_broken,
        params: {
          id: anime_video_report.id
        },
        format: :json
    end
    let(:kind) { 'other' }

    it do
      expect(anime_video.reload.state).to eq 'broken'
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#close_edit' do
    before do
      post :close_edit,
        params: {
          id: anime_video_report.id
        }
    end

    it do
      expect(anime_video_report.reload).to be_accepted
      expect(anime_video.reload).to be_working
      expect(response).to redirect_to edit_video_online_url(
        anime_video.anime,
        anime_video,
        host: AnimeOnlineDomain.host(anime_video.anime)
      )
    end
  end

  describe '#cancel' do
    let(:anime_video) { create :anime_video, anime: create(:anime), state: state }
    let!(:anime_video_report) do
      create :anime_video_report,
        user: user_2,
        kind: kind,
        anime_video: anime_video,
        state: 'accepted'
    end
    let(:state) { kind }

    before do
      post :cancel,
        params: {
          id: anime_video_report.id
        },
        format: :json
    end

    context 'broken' do
      let(:kind) { 'broken' }
      it do
        expect(anime_video.reload).to be_working
        expect(response.content_type).to eq 'application/json'
        expect(response).to have_http_status :success
      end
    end

    context 'wrong' do
      let(:kind) { 'wrong' }
      it do
        expect(anime_video.reload).to be_working
        expect(response.content_type).to eq 'application/json'
        expect(response).to have_http_status :success
      end
    end

    context 'uploaded' do
      let(:kind) { 'uploaded' }

      context 'rejected' do
        let(:state) { 'rejected' }
        it do
          expect(anime_video.reload).to be_uploaded
          expect(response.content_type).to eq 'application/json'
          expect(response).to have_http_status :success
        end
      end

      context 'rejected' do
        let(:state) { 'working' }
        it do
          expect(anime_video.reload).to be_uploaded
          expect(response.content_type).to eq 'application/json'
          expect(response).to have_http_status :success
        end
      end
    end
  end

  describe '#reject' do
    before do
      post :reject,
        params: {
          id: anime_video_report.id
        },
        format: :json
    end

    context 'broken' do
      let(:kind) { 'broken' }
      it do
        expect(anime_video.reload.state).to eq 'working'
        expect(response.content_type).to eq 'application/json'
        expect(response).to have_http_status :success
      end
    end

    context 'wrong' do
      let(:kind) { 'wrong' }
      it do
        expect(anime_video.reload.state).to eq 'working'
        expect(response.content_type).to eq 'application/json'
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#destroy' do
    before do
      delete :destroy,
        params: {
          id: anime_video_report.id
        },
        format: :json
    end

    context 'uploaded' do
      let(:kind) { 'uploaded' }
      it do
        expect { anime_video.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { anime_video_report.reload }.to raise_error ActiveRecord::RecordNotFound

        expect(response.content_type).to eq 'application/json'
        expect(response).to have_http_status :success
      end
    end

    context 'not uploaded' do
      let(:kind) { %i[broken wrong other].sample }
      it do
        expect(anime_video.reload).to be_working
        expect { anime_video_report.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(response.content_type).to eq 'application/json'
        expect(response).to have_http_status :success
      end
    end
  end
end
