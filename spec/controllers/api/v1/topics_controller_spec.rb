describe Api::V1::TopicsController, :show_in_doc do
  describe '#index' do
    let!(:topic) do
      create :topic,
        forum: animanga_forum,
        body: 'test [spoiler=спойлер]test[/spoiler] test'
    end
    before { get :index, params: { forum: animanga_forum.permalink }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#show' do
    let(:review) { create :review }
    let(:topic) do
      create :review_topic,
        linked: review,
        body: 'test [spoiler=спойлер]test[/spoiler] test'
    end

    before { get :show, params: { id: topic.id }, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#updates' do
    let(:anime) { create :anime }
    let!(:topic) do
      create :topic,
        forum: animanga_forum,
        generated: true,
        linked: anime,
        action: 'episode',
        value: '5'
    end
    before { get :updates, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
