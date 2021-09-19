describe Reviews::Query do
  let(:entry) { create :anime }

  before do
    Review.wo_antispam do
      @reviews = [
        create(:review, anime: entry, user: user),
        create(:review, anime: entry, user: user, created_at: Reviews::Query::NEW_REVIEW_BUBBLE_INTERVAL.ago),
        create(:review, anime: entry, user: user)
      ]
    end
  end

  describe '#fetch' do
    subject { query.fetch.to_a }

    describe 'with_id' do
      let(:query) { Reviews::Query.new entry, user, @reviews[0].id }

      it 'has 1 item' do
        expect(subject.size).to eq(1)
      end
      its(:first) { is_expected.to eq @reviews[0] }
    end

    describe 'without_id' do
      let(:query) { Reviews::Query.new entry, user }

      it 'has 3 items' do
        is_expected.to have(3).items
      end
      its(:last) { is_expected.to eq @reviews[1] }
      its(:first) { is_expected.to eq @reviews[2] }
    end
  end
end
