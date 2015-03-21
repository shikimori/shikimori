describe Api::V1::CharactersController, :show_in_doc do
  describe '#show' do
    let(:character) { create :character, :with_thread }
    before { get :show, id: character.id, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
