describe Moderations::NewsController do
  let!(:news_topic) { create :news_topic, forum_id: Forum::PREMODERATION_ID }

  describe '#index' do
    include_context :authenticated
    subject! { get :index }

    it { expect(response).to have_http_status :success }
  end

  describe '#accept' do
    include_context :authenticated, :news_moderator
    subject! { post :accept, params: { id: news_topic.id } }
    let(:news_topic) { create :news_topic }

    it do
      expect(resource.forum_id).to eq Forum::NEWS_ID
      expect(response).to redirect_to moderations_news_index_url
    end
  end

  describe '#reject' do
    include_context :authenticated, :news_moderator
    subject! { post :reject, params: { id: news_topic.id } }

    it do
      expect(resource.forum_id).to eq Forum::OFFTOPIC_ID
      expect(response).to redirect_to moderations_news_index_url
    end
  end
end
