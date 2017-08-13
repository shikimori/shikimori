describe VotesController do
  include_context :authenticated, :user
  let(:votable) { create :review }

  describe '#create' do
    before do
      post :create,
        params: {
          id: votable.to_param,
          type: votable.class.name,
          voting: 'yes'
        }
    end

    it do
      expect(user.liked? votable).to eq true
      expect(response).to be_success
    end
  end
end
