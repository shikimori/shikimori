describe Api::V2::Topics::IgnoresController, :show_in_doc do
  include_context :authenticated, :user

  let(:topic) { seed :offtopic_topic }

  describe '#create' do
    before { post :create, params: { topic_id: topic.id } }

    it do
      expect(user.topic_ignores).to have(1).item
      expect(user.topic_ignores.first).to have_attributes topic_id: topic.id
      expect(response).to have_http_status :success
    end
  end

  describe '#destroy' do
    let!(:topic_ignore) { create :topic_ignore, user: user, topic: topic }
    before { delete :destroy, params: { topic_id: topic.id } }

    it do
      expect { topic_ignore.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(response).to have_http_status :success
    end
  end
end
