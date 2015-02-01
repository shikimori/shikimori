describe Api::V1::TopicsController, :show_in_doc do
  describe '#index' do
    let(:section) { create :section }
    let!(:topic) { create :entry, section: section, text: 'test [spoiler=спойлер]test[/spoiler] test' }

    before { get :index, section: section.permalink, format: :json }

    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'application/json' }
  end

  describe '#show' do
    let(:review) { create :review }
    let(:topic) { create :review_comment, linked: review, text: 'test [spoiler=спойлер]test[/spoiler] test' }

    before { get :show, id: topic.id, format: :json }

    it { expect(response).to have_http_status :success }
  end
end
