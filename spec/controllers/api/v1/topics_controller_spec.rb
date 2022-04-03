describe Api::V1::TopicsController do
  let(:anime) { create :anime }

  describe '#index', :show_in_doc do
    let!(:topic) do
      create :topic,
        forum: animanga_forum,
        body: 'test [spoiler=спойлер]test[/spoiler] test',
        linked: anime
    end
    let(:anime) { create :anime }
    subject! do
      get :index,
        params: {
          forum: animanga_forum.permalink,
          linked_id: anime.id,
          linked_type: Anime.name
        },
        format: :json
    end

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#show', :show_in_doc do
    let(:critique) { create :critique }
    let(:topic) do
      create :critique_topic,
        linked: critique,
        body: 'test [spoiler=спойлер]test[/spoiler] test'
    end

    subject! { get :show, params: { id: topic.id }, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#updates', :show_in_doc do
    let(:anime) { create :anime }
    let!(:topic) do
      create :topic,
        forum: animanga_forum,
        generated: true,
        linked: anime,
        action: 'episode',
        value: '5'
    end
    subject! { get :updates, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#hot', :show_in_doc do
    let(:anime) { create :anime }
    let!(:topic) do
      create :topic,
        forum: animanga_forum,
        generated: true,
        linked: anime,
        action: 'episode',
        value: '5'
    end
    before { allow(Topics::HotTopicsQuery).to receive(:call).and_return [topic] }
    subject! { get :hot, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#create' do
    include_context :authenticated, :user, :week_registered
    subject! { post :create, params: { topic: params }, format: :json }

    let(:params) do
      {
        user_id: user.id,
        forum_id: forum_id,
        title: title,
        body: 'text',
        type: Topic.name,
        linked_id: anime.id,
        linked_type: Anime.name
      }
    end
    let(:forum_id) { animanga_forum.id }
    let(:title) { 'zxc' }

    context 'success', :show_in_doc do
      it_behaves_like :successful_resource_change, :api
    end

    context 'failure' do
      context 'title change' do
        let(:title) { '' }
        it_behaves_like :failed_resource_change, true
      end

      context 'forum_id change' do
        let(:forum_id) { 0 }
        it_behaves_like :failed_resource_change
      end
    end
  end

  describe '#update' do
    include_context :authenticated, :user, :week_registered
    subject! { patch :update, params: { id: topic.id, topic: params }, format: :json }
    let(:topic) { create :topic, user: user }

    context 'success', :show_in_doc do
      let(:params) { { body: 'blablalbla' } }
      it_behaves_like :successful_resource_change, :api
    end

    context 'failure' do
      let(:params) { { title: 'blablalbla' } }
      it_behaves_like :failed_resource_change
    end
  end

  describe '#destroy' do
    include_context :authenticated, :user, :week_registered
    let(:make_request) { delete :destroy, params: { id: topic.id }, format: :json }

    context 'success', :show_in_doc do
      subject! { make_request }
      let(:topic) { create :topic, user: user }

      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(json[:notice]).to eq 'Топик удалён'
      end
    end

    context 'forbidden' do
      let(:topic) { create :topic }
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end
end
