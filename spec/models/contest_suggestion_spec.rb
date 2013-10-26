require 'spec_helper'

describe ContestSuggestion do
  context :relations do
    it { should belong_to :user }
    it { should belong_to :contest }
    it { should belong_to :item }
  end

  context :validations do
    it { should validate_presence_of :contest }
    it { should validate_presence_of :user }
    it { should validate_presence_of :item }
  end

  let(:user) { create :user }
  let(:contest) { create :contest }
  let(:item) { create :anime }

  context :scopes do
    let(:item2) { create :anime }
    let!(:suggestion1) { create :contest_suggestion, contest: contest, item: item }
    let!(:suggestion2) { create :contest_suggestion, contest: contest, user: user, item: item }
    let!(:suggestion3) { create :contest_suggestion, contest: contest, user: user, item: item2 }

    describe :by_user do
      it { ContestSuggestion.by_user(user).should eq [suggestion2, suggestion3] }
    end

    describe :by_votes do
      it { ContestSuggestion.by_votes.should eq [suggestion1, suggestion3] }
      it { ContestSuggestion.by_votes.first.votes.should eq 2 }
    end
  end

  context :class_methods do
    describe :suggest do
      subject(:act) { ContestSuggestion.suggest contest, user, item }

      it { expect{act}.to change(ContestSuggestion, :count).by 1 }

      describe 'new suggestion' do
        subject { contest.suggestions.first }
        before { act }

        its(:item_id) { should eq item.id }
        its(:item_type) { should eq item.class.name }
        its(:user_id) { should eq user.id }
      end

      describe 'already made suggestion' do
        let!(:suggestion) { create :contest_suggestion, item: item, user: user, contest: contest }
        it { expect{act}.to change(ContestSuggestion, :count).by 0 }
      end

      describe 'too many suggestion' do
        let!(:suggestion1) { create :contest_suggestion, item: create(:anime), user: user, contest: contest }
        let!(:suggestion2) { create :contest_suggestion, item: create(:anime), user: user, contest: contest }
        it { expect{act}.to change(ContestSuggestion, :count).by 0 }
      end
    end
  end
end
