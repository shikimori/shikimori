describe Moderations::NewsController do
  let!(:news_topic) { create :news_topic, forum_id: Forum::PREMODERATION_ID }

  describe '#index' do
    include_context :authenticated
    subject! { get :index }

    it { expect(response).to have_http_status :success }
  end

  describe '#accept' do
    let(:make_request) { post :accept, params: { id: news_topic.id } }

    context 'has access' do
      include_context :authenticated, :news_moderator
      subject! { make_request }

      it do
        expect(resource.forum_id).to eq Forum::NEWS_ID
        expect(response).to redirect_to moderations_news_index_url
      end
    end

    context 'no access' do
      include_context :authenticated, :forum_moderator
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#reject' do
    let(:make_request) { post :reject, params: { id: news_topic.id } }

    context 'has access' do
      include_context :authenticated, :news_moderator
      subject! { make_request }

      it do
        expect(resource.forum_id).to eq Forum::OFFTOPIC_ID
        expect(response).to redirect_to moderations_news_index_url
      end
    end

    context 'no access' do
      include_context :authenticated, :forum_moderator
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end
end
