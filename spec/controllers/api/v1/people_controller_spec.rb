describe Api::V1::PeopleController, :type => :controller do
  describe :show do
    before { get :show, id: person.id, format: :json }

    context :person do
      let(:person) { create :person }
      it { should respond_with :success }
      it { should respond_with_content_type :json }
    end

    context :seyu do
      let(:person) { create :person, seyu: true }
      it { should respond_with :success }
      it { should respond_with_content_type :json }
    end
  end
end
