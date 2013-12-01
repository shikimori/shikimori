require 'spec_helper'

describe Api::V1::Profile::MessagesController do
  let(:user) { create :user }
  before { sign_in user }

  describe :index do
    let(:user_2) { create :user }

    describe :inbox do
      let!(:private) { create :message, kind: MessageType::Private, dst: user, src: user_2, body: '[b]test[/b]' }
      before { get :index, page: 1, limit: 20, type: 'inbox' }

      it { should respond_with :success }
    end

    describe :news do
      let(:topic) { create :anime_news, linked: create(:anime) }
      let!(:news) { create :message, kind: MessageType::Anons, dst: user, src: user_2, body: 'anime [b]anons[/b]', linked: topic }
      before { get :index, page: 1, limit: 20, type: 'news' }

      it { should respond_with :success }
    end

      #let!(:sent) { create :message, kind: MessageType::Private, dst: user_2, src: user }
      #let!(:news) { create :message, kind: MessageType::Anons, dst: user, src: user_2 }
      #let!(:notification) { create :message, kind: MessageType::FriendRequest, dst: user, src: user_2, read: true }
  end

  describe :unread do
    before { get :unread }
    it { should respond_with :success }
  end
end
