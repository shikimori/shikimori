describe Api::V1::CharactersController do
  describe '#show' do
    let(:character) { create :character, :with_thread }
    before { get :show, id: character.id, format: :json }

    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
