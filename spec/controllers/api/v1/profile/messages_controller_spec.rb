require 'spec_helper'

describe Api::V1::Profile::MessagesController do
  let(:user) { create :user }
  before { sign_in user }

  describe :index do
    let(:user_2) { create :user }
    let(:topic) { create :anime_news, linked: create(:anime) }
    let!(:news) { create :message, kind: MessageType::Anons, dst: user, src: user_2, body: 'anime [b]anons[/b]', linked: topic }
    before { get :index, page: 1, limit: 20, type: 'news' }

    it { should respond_with :success }
  end

  describe :unread do
    before { get :unread }
    it { should respond_with :success }
  end
end
