describe ContestSuggestionsController do
  include_context :authenticated, :user
  let(:contest) { create :contest, state: 'proposing' }

  describe '#show' do
    before { get :show, params: { contest_id: contest.id, id: suggestion.id } }
    let(:suggestion) { create :contest_suggestion, contest: contest, user: user }
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    let(:make_request) { post :create, params: { contest_id: contest.id, contest_suggestion: { item_id: anime.id, item_type: anime.class.name } } }
    let(:anime) { create :anime }

    context 'valid record' do
      before { allow(ContestSuggestion).to receive :suggest }
      before { make_request }

      it { expect(response).to redirect_to contest }
      it { expect(ContestSuggestion).to have_received(:suggest).with contest, user, anime }
    end

    context 'started contest' do
      let(:contest) { create :contest, state: 'started' }
      it { expect { make_request }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'invalid item' do
      let(:anime) { build :anime }
      it { expect { make_request }.to raise_error ActiveRecord::RecordNotFound }
    end
  end

  describe '#destroy' do
    subject(:make_request) { delete :destroy, params: { contest_id: contest.id, id: suggestion } }
    let(:suggestion) { create :contest_suggestion, contest: contest, user: user }

    context 'valid record' do
      before { make_request }
      it { expect(response).to redirect_to contest }
      it { expect { suggestion.reload }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'wrong record' do
      before { sign_in create(:user) }
      it { expect { make_request }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'started contest' do
      let(:contest) { create :contest, state: 'started' }
      it { expect { make_request }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end
