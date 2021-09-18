describe Critiques::Query do
  let(:entry) { create :anime }

  before do
    Critique.wo_antispam do
      @reviews = [
        create(:review, target: entry, user: user),
        create(:review, target: entry, user: user, created_at: Critiques::Query::NEW_REVIEW_BUBBLE_INTERVAL.ago),
        create(:review, target: entry, user: user),
        create(:review, target: entry, user: user, locale: :en)
      ]
    end
  end

  describe 'fetch' do
    subject { query.fetch.to_a }
    let(:locale) { :ru }

    describe 'with_id' do
      let(:query) { Critiques::Query.new entry, user, locale, @reviews[0].id }

      it 'has 1 item' do
        expect(subject.size).to eq(1)
      end
      its(:first) { is_expected.to eq @reviews[0] }
    end

    describe 'without_id' do
      let(:query) { Critiques::Query.new entry, user, locale }

      it 'has 3 items' do
        is_expected.to have(3).items
      end
      its(:last) { is_expected.to eq @reviews[1] }
      its(:first) { is_expected.to eq @reviews[2] }
    end
  end
end
