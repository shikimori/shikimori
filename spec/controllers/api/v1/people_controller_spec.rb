describe Api::V1::PeopleController, :show_in_doc do
  describe '#show' do
    before { get :show, id: person.id, format: :json }

    context 'person' do
      let(:person) { create :person }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
      end
    end

    context 'seyu' do
      let(:person) { create :person, seyu: true }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
      end
    end
  end
end
