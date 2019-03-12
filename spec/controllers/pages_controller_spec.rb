describe PagesController do
  describe '#ongoings' do
    let!(:ongoing) { create :anime, :ongoing }
    let!(:anons) { create :anime, :anons }
    let!(:topic) { create :topic, id: PagesController::ONGOINGS_TOPIC_ID }
    before { get :ongoings }

    it { expect(response).to have_http_status :success }
  end

  describe '#about', :vcr do
    let!(:topic) { create :topic, id: PagesController::ABOUT_TOPIC_ID }
    include_context :timecop, '2015-11-02'

    before { get :about }

    it { expect(response).to have_http_status :success }
  end

  describe '#copyrighted' do
    let!(:topic) { create :topic, id: PagesController::COPYRIGHTED_TOPIC_ID }
    before { get :copyrighted }
    it { expect(response).to have_http_status :success }
  end

  describe '#news_feed' do
    let!(:news_topic) do
      create :news_topic,
        generated: false,
        forum: animanga_forum,
        linked: create(:anime),
        action: AnimeHistoryAction::Anons
    end
    before { get :news_feed, format: :rss }

    it do
      expect(assigns :collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/rss+xml'
    end
  end

  describe '#terms' do
    before { get :terms }
    it { expect(response).to have_http_status :success }
  end

  describe '#privacy' do
    before { get :privacy }
    it { expect(response).to have_http_status :success }
  end

  describe '#for_right_holders' do
    before { get :for_right_holders }
    it { expect(response).to have_http_status :success }
  end

  # describe 'pages404' do
    # before { get :page404 }
    # it { is_expected.to respond_with 404 }
  # end

  # describe 'pages503' do
    # before { get :page503 }
    # it { is_expected.to respond_with 503 }
  # end

  describe 'feedback' do
    let!(:guest) { create :user, :guest }
    before { get :feedback }
    it { expect(response).to have_http_status :success }
  end

  describe 'admin_panel' do
    context 'guest' do
      before { get :admin_panel }
      it { is_expected.to respond_with 403 }
    end

    context 'user' do
      include_context :authenticated, :user
      before { get :admin_panel }
      it { is_expected.to respond_with 403 }
    end

    context 'admin' do
      include_context :authenticated, :admin

      before { allow_any_instance_of(PagesController).to receive(:`).and_return '' }
      before { allow(Rails.application.redis).to receive(:info).and_return('db0' => '=,') }
      before { get :admin_panel }

      it { expect(response).to have_http_status :success }
    end
  end

  describe 'user_agent' do
    before { get :user_agent }
    it { expect(response).to have_http_status :success }
  end

  describe 'tableau' do
    before { get :tableau }

    it do
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end
end
