describe VotesController do
  include_context :authenticated, :user

  describe '#create' do
    let(:make_request) do
      post :create,
        params: {
          votable_id: votable.to_param,
          votable_type: votable.class.name,
          vote: 'yes'
        }
    end
    let(:votable) { create :critique, user: user_2 }

    describe 'vote' do
      subject! { make_request }
      it do
        expect(user.liked? votable).to eq true
        expect(response).to have_http_status :success
      end
    end

    describe 'Votable::Vote call' do
      before do
        allow(Votable::Vote).to receive :call
      end
      subject! { make_request }

      it do
        expect(Votable::Vote)
          .to have_received(:call)
          .with(
            votable: votable,
            voter: user,
            vote: 'yes'
          )
        expect(response).to have_http_status :success
      end
    end
  end
end
