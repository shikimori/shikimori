describe PagesController do
  include_context :seeds
  let(:user) { create :user }

  describe '#ongoings' do
    let!(:ongoing) { create :anime, :ongoing }
    let!(:anons) { create :anime, :anons }
    let!(:topic) { create :topic, id: PagesController::ONGOINGS_TOPIC_ID }
    before { get :ongoings }

    it { expect(response).to have_http_status :success }
  end

  describe '#about', :vcr do
    let!(:topic) { create :topic, id: PagesController::ABOUT_TOPIC_ID }
    before { Timecop.freeze '2015-11-02' }
    after { Timecop.return }

    before { get :about }

    it { expect(response).to have_http_status :success }
  end

  describe '#info' do
    before { get :info }
    it { expect(response).to have_http_status :success }
  end

  describe '#news_feed' do
    let!(:news) { create :news_topic, generated: false, forum: animanga_forum,
      linked: create(:anime), action: AnimeHistoryAction::Anons }
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

  describe 'pages404' do
    before { get :page404 }
    it { should respond_with 404 }
  end

  describe 'pages503' do
    before { get :page503 }
    it { should respond_with 503 }
  end

  describe 'feedback' do
    before do
      create :user, id: 1
      create :user, id: User::GUEST_ID
      get :feedback
    end

    it { expect(response).to have_http_status :success }
  end

  describe 'admin_panel' do
    context 'guest' do
      before { get :admin_panel }
      it { should respond_with 403 }
    end

    context 'user' do
      include_context :authenticated, :user
      before { get :admin_panel }
      it { should respond_with 403 }
    end

    context 'admin' do
      include_context :authenticated, :admin

      before { allow_any_instance_of(PagesController).to receive(:`).and_return '' }
      before { allow($redis).to receive(:info).and_return('db0' => '=,') }
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
