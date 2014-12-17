describe Api::V1::TopicsController do
  describe 'index' do
    let(:section) { create :section }
    let!(:topic) { create :entry, section: section, text: 'test [spoiler=спойлер]test[/spoiler] test' }

    before { get :index, section: section.permalink, format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
    specify { expect(assigns(:topics).size).to eq(1) }
  end

  describe 'show' do
    let(:review) { create :review }
    let(:topic) { create :review_comment, linked: review, text: 'test [spoiler=спойлер]test[/spoiler] test' }

    before { get :show, id: topic.id, format: :json }

    it { should respond_with :success }
  end
end
