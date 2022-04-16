describe Moderations::ArticlesController do
  describe '#index' do
    include_context :authenticated
    let!(:article) { create :article, :with_topics }
    subject! { get :index }

    it { expect(response).to have_http_status :success }
  end

  describe '#accept' do
    include_context :authenticated, :article_moderator
    subject! { post :accept, params: { id: article.id } }
    let(:article) { create :article }

    it do
      expect(resource).to be_moderation_accepted
      expect(response).to redirect_to moderations_articles_url
    end
  end

  describe '#reject' do
    include_context :authenticated, :article_moderator
    subject! { post :reject, params: { id: article.id } }
    let(:article) { create :article, :with_topics }

    it do
      expect(resource).to be_moderation_rejected
      expect(response).to redirect_to moderations_articles_url
    end
  end

  describe '#cancel' do
    include_context :authenticated, :article_moderator
    subject! { post :cancel, params: { id: article.id } }
    let(:article) { create :article, :accepted, approver: user }

    it do
      expect(resource).to be_moderation_pending
      expect(response).to redirect_to moderations_articles_url
    end
  end
end
