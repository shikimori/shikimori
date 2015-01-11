describe Api::V1::CharactersController do
  describe '#show' do
    let(:character) { create :character, :with_thread }
    before { get :show, id: character.id, format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
