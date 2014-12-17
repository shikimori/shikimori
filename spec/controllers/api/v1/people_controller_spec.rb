describe Api::V1::PeopleController do
  describe 'show' do
    before { get :show, id: person.id, format: :json }

    context 'person' do
      let(:person) { create :person }
      it { should respond_with :success }
      it { expect(response.content_type).to eq 'application/json' }
    end

    context 'seyu' do
      let(:person) { create :person, seyu: true }
      it { should respond_with :success }
      it { expect(response.content_type).to eq 'application/json' }
    end
  end
end
