describe Moderations::PostersController do
  let(:manga) { create :manga }
  let!(:poster) { create :poster, manga: }

  describe '#index' do
    include_context :authenticated, :super_moderator
    subject! { get :index }

    it { expect(response).to have_http_status :success }
  end

  describe '#accept' do
    include_context :authenticated, :super_moderator
    subject! { post :accept, params: { id: poster.id } }

    it do
      expect(resource).to be_moderation_accepted
      expect(resource).to_not be_changed
      expect(response).to redirect_to moderations_posters_url
    end
  end

  describe '#reject' do
    include_context :authenticated, :super_moderator
    subject! { post :reject, params: { id: poster.id } }

    it do
      expect(resource).to be_moderation_rejected
      expect(resource).to_not be_changed
      expect(response).to redirect_to moderations_posters_url
    end
  end

  describe '#cancel' do
    include_context :authenticated, :super_moderator
    subject! { post :cancel, params: { id: poster.id } }
    let(:poster) { create :poster, :accepted, manga:, approver: user }

    it do
      expect(resource).to be_moderation_pending
      expect(resource).to_not be_changed
      expect(response).to redirect_to moderations_posters_url
    end
  end
end
