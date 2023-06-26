describe ContestSuggestion do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :contest }
    it { is_expected.to belong_to :item }
  end

  let(:contest) { create :contest }
  let(:item) { create :anime }

  context 'scopes' do
    let(:item2) { create :anime }
    let!(:suggestion1) { create :contest_suggestion, contest: contest, item: item }
    let!(:suggestion2) { create :contest_suggestion, contest: contest, user: user, item: item }
    let!(:suggestion3) { create :contest_suggestion, contest: contest, user: user, item: item2 }

    describe 'by_user' do
      it { expect(ContestSuggestion.by_user(user)).to eq [suggestion2, suggestion3] }
    end

    describe 'by_votes' do
      it { expect(ContestSuggestion.by_votes.map(&:item)).to eq [item, item2] }
      it { expect(ContestSuggestion.by_votes.first.votes).to eq 2 }
    end
  end

  context 'class_methods' do
    describe 'suggest' do
      subject(:act) { ContestSuggestion.suggest contest, user, item }

      it { expect { act }.to change(ContestSuggestion, :count).by 1 }

      describe 'new suggestion' do
        subject { contest.suggestions.first }
        before { act }

        its(:item_id) { is_expected.to eq item.id }
        its(:item_type) { is_expected.to eq item.class.name }
        its(:user_id) { is_expected.to eq user.id }
      end

      describe 'already made suggestion' do
        let!(:suggestion) { create :contest_suggestion, item: item, user: user, contest: contest }
        it { expect { act }.to change(ContestSuggestion, :count).by 0 }
      end

      describe 'too many suggestion' do
        let!(:suggestion1) { create :contest_suggestion, item: create(:anime), user: user, contest: contest }
        let!(:suggestion2) { create :contest_suggestion, item: create(:anime), user: user, contest: contest }
        it { expect { act }.to change(ContestSuggestion, :count).by 0 }
      end
    end
  end
end
