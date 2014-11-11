describe VotesController do
  let (:user) { FactoryGirl.create :user }
  let (:entry) { FactoryGirl.create :review }
  let (:defaults) { { id: entry.to_param, type: entry.class.name, voting: 'yes' } }

  describe "create" do
    it "forbidden" do
      post :create, defaults
      response.should be_redirect
    end

    describe 'sign_in user' do
      before (:each) { sign_in user }

      it 'success' do
        post :create, defaults
        response.should be_success
      end

      it 'only once' do
        expect {
          post :create, defaults
          post :create, defaults.merge(voting: 'no')
        }.to change(Vote, :count).by(1)

        user.votes.first.voting.should be_false

        response.should be_success
      end

      it 'forbidden for own' do
        entry2 =  FactoryGirl.create :review, user: user
        post :create, id: entry2.to_param, type: entry2.class.name, voting: 'yes'
        response.should be_forbidden
      end
    end
  end
end
