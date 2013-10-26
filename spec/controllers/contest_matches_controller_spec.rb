require 'spec_helper'

describe ContestMatchesController do
  let(:match) { create :contest_match, state: 'started' }

  describe :show do
    before { get :show, contest_id: match.round.contest_id, id: match.id }
    it { should respond_with :success }
  end

  describe :vote do
    let(:user) { create :user }
    before { sign_in user }

    context 'new vote' do
      before { post :vote, contest_id: match.round.contest_id, id: match.id, variant: 'left' }

      it { should respond_with :success }
      it { should respond_with_content_type :json }
      it { assigns(:match).votes.should have(1).item }
    end

    context 'has user_id vote' do
      before do
        match.vote_for 'left', user, '123'
        post :vote, contest_id: match.round.contest_id, id: match.id, variant: 'right'
      end
      let(:json) { JSON.parse response.body }

      it { should respond_with :success }
      it { should respond_with_content_type :json }
      it { assigns(:match).votes.should have(1).item }
      it { json['variant'].should eq 'right' }
      it { json['vote_id'].should eq match.id }
    end

    context 'has ip vote' do
      before do
        match.vote_for 'left', create(:user), '0.0.0.0'
        post :vote, contest_id: match.round.contest_id, id: match.id, variant: 'right'
      end

      it { should respond_with 422 }
      it { should respond_with_content_type :json }
      it { assigns(:match).votes.should have(1).item }
    end
  end
end
