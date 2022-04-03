describe PagesController do
  describe '#ongoings' do
    let!(:ongoing) { create :anime, :ongoing }
    let!(:anons) { create :anime, :anons }
    let!(:topic) { create :topic, id: PagesController::ONGOINGS_TOPIC_ID }
    subject! { get :ongoings }

    it { expect(response).to have_http_status :success }
  end

  describe '#about', :vcr do
    let!(:topic) { create :topic, id: PagesController::ABOUT_TOPIC_ID }
    include_context :timecop, '2020-07-07'

    subject! { get :about }

    it { expect(response).to have_http_status :success }
  end

  describe '#news_feed' do
    let!(:news_topic) { create :news_topic }
    subject! { get :news_feed, format: :rss }

    it do
      expect(assigns :collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/rss+xml; charset=utf-8'
    end
  end

  describe '#terms' do
    subject! { get :terms }
    it { expect(response).to have_http_status :success }
  end

  describe '#privacy' do
    subject! { get :privacy }
    it { expect(response).to have_http_status :success }
  end

  describe '#for_right_holders' do
    subject! { get :for_right_holders }
    it { expect(response).to have_http_status :success }
  end

  # describe 'pages404' do
    # subject! { get :page404 }
    # it { is_expected.to respond_with 404 }
  # end

  # describe 'pages503' do
    # subject! { get :page503 }
    # it { is_expected.to respond_with 503 }
  # end

  describe 'feedback' do
    let!(:guest) { create :user, :guest }
    subject! { get :feedback }
    it { expect(response).to have_http_status :success }
  end

  describe 'admin_panel' do
    subject { get :admin_panel }
    context 'guest' do
      it { expect { subject }.to raise_error CanCan::AccessDenied }
    end

    context 'user' do
      include_context :authenticated, :user
      it { expect { subject }.to raise_error CanCan::AccessDenied }
    end

    context 'admin' do
      include_context :authenticated, :admin

      before do
        allow_any_instance_of(PagesController).to receive(:`).and_return ''
        allow(Rails.application.redis).to receive(:info).and_return('db0' => '=,')
      end
      before { subject }

      it { expect(response).to have_http_status :success }
    end
  end

  describe 'user_agent' do
    subject! { get :user_agent }
    it { expect(response).to have_http_status :success }
  end

  describe 'tableau' do
    subject! { get :tableau }

    it do
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end
end
