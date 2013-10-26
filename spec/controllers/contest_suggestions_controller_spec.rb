require 'spec_helper'

describe ContestSuggestionsController do
  let(:user) { create :user }
  before { sign_in user }
  let(:contest) { create :contest, state: 'proposing' }

  describe :show do
    before { get :show, contest_id: contest.id, id: suggestion.id }
    let(:suggestion) { create :contest_suggestion, contest: contest, user: user }
    it { should respond_with :success }
  end

  describe :create do
    subject(:act) { post :create, contest_id: contest.id, contest_suggestion: { item_id: anime.id, item_type: anime.class.name } }
    let(:anime) { create :anime }

    context 'valid record' do
      it { should redirect_to contest }

      describe :entry do
        after { act }
        it { ContestSuggestion.should_receive(:suggest).with contest, user, anime }
      end
    end

    context 'started contest' do
      let(:contest) { create :contest, state: 'started' }
      it { expect{act}.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'invalid item' do
      let(:anime) { build :anime }
      it { expect{act}.to raise_error ActiveRecord::RecordNotFound }
    end
  end

  describe :destroy do
    subject(:act) { delete :destroy, contest_id: contest.id, id: suggestion }
    let(:suggestion) { create :contest_suggestion, contest: contest, user: user }

    context 'valid record' do
      before { act }
      it { should redirect_to contest }
      it { expect{suggestion.reload}.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'wrong record' do
      before { sign_in create(:user) }
      it { expect{act}.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'started contest' do
      let(:contest) { create :contest, state: 'started' }
      it { expect{act}.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end
