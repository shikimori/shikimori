describe ContestMatchesController do
  let(:match) { create :contest_match, state: 'started' }

  describe '#show' do
    before do
      get :show,
        params: {
          contest_id: match.round.contest_id,
          id: match.id
        }
    end

    it do
      expect(resource).to eq match
      expect(response).to have_http_status :success
    end
  end
end
