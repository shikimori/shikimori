describe VotesController do
  let(:user) { FactoryGirl.create :user }
  let(:entry) { FactoryGirl.create :review }
  let(:params) do
    {
      id: entry.to_param,
      type: entry.class.name,
      voting: 'yes'
    }
  end

  describe '#create' do
    it 'guest' do
      post :create, params: params
      expect(response).to be_redirect
    end

    describe 'sign_in user' do
      before { sign_in user }

      it 'success' do
        post :create, params: params
        expect(response).to be_success
      end

      it 'only once' do
        expect {
          post :create, params: params
          post :create, params: params.merge(voting: 'no')
        }.to change(Vote, :count).by(1)

        expect(user.votes.first.voting).to be_falsy

        expect(response).to be_success
      end

      # it 'forbidden for own' do
        # entry2 =  FactoryGirl.create :review, user: user
        # post :create, params: { id: entry2.to_param, type: entry2.class.name, voting: 'yes' }
        # expect(response).to be_forbidden
      # end
    end
  end
end
