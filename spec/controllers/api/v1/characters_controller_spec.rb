describe Api::V1::CharactersController, :type => :controller do
  describe 'show' do
    let(:character) { create :character }
    before { get :show, id: character.id, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end
end
