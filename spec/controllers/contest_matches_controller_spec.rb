describe ContestMatchesController do
  let(:match) { create :contest_match, state: 'started' }

  describe '#show' do
    before { get :show, params: { contest_id: match.round.contest_id, id: match.id } }
    it { expect(response).to have_http_status :success }
  end

  # describe '#vote' do
    # let(:user) { create :user }
    # before { sign_in user }

    # context 'new vote' do
      # before { post :vote, params: { contest_id: match.round.contest_id, id: match.id, variant: 'left' } }

      # it do
        # expect(assigns(:match).votes).to have(1).item
        # expect(response.content_type).to eq 'application/json'
        # expect(response).to have_http_status :success
      # end
    # end

    # context 'has user_id vote' do
      # before do
        # match.vote_for 'left', user, '123'
        # post :vote, params: { contest_id: match.round.contest_id, id: match.id, variant: 'right' }
      # end
      # let(:json) { JSON.parse response.body }

      # it do
        # expect(assigns(:match).votes).to have(1).item
        # expect(json['variant']).to eq 'right'
        # expect(json['vote_id']).to eq match.id
        # expect(response.content_type).to eq 'application/json'
        # expect(response).to have_http_status :success
      # end
    # end

    # context 'has ip vote' do
      # before do
        # match.vote_for 'left', create(:user), '0.0.0.0'
        # post :vote, params: { contest_id: match.round.contest_id, id: match.id, variant: 'right' }
      # end

      # it do
        # expect(assigns(:match).votes).to have(1).item
        # expect(response.content_type).to eq 'application/json'
        # expect(response).to have_http_status 422
      # end
    # end
  # end
end
