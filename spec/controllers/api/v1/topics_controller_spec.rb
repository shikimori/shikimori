describe Api::V1::TopicsController, :show_in_doc do
  include_context :seeds

  describe '#index' do
    let!(:topic) { create :entry, section: animanga_section, text: 'test [spoiler=спойлер]test[/spoiler] test' }

    before { get :index, section: animanga_section.permalink, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#show' do
    let(:review) { create :review }
    let(:topic) { create :review_comment, linked: review, text: 'test [spoiler=спойлер]test[/spoiler] test' }

    before { get :show, id: topic.id, format: :json }

    it { expect(response).to have_http_status :success }
  end
end
