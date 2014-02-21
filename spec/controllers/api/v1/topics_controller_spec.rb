describe Api::V1::TopicsController do
  describe :index do
    let(:section) { create :section }
    let!(:topic) { create :entry, section: section, text: 'test [spoiler=спойлер]test[/spoiler] test' }

    before { get :index, section: section.permalink, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
    specify { assigns(:topics).should have(1).item }
  end
end
