describe Api::V1::TopicsController, :show_in_doc do
  include_context :seeds

  describe '#index' do
    let!(:topic) do
      create :entry, forum: animanga_forum,
        body: 'test [spoiler=спойлер]test[/spoiler] test'
    end
    before { get :index, forum: animanga_forum.permalink, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#show' do
    let(:review) { create :review }
    let(:topic) do
      create :review_topic, linked: review,
        body: 'test [spoiler=спойлер]test[/spoiler] test'
    end

    before { get :show, id: topic.id, format: :json }

    it { expect(response).to have_http_status :success }
  end
end
