describe ReviewsQuery do
  let(:user) { build_stubbed :user }
  let(:entry) { create :anime }

  before do
    Review.wo_antispam do
      @reviews = [
        create(:review, target: entry, user: user),
        create(:review, target: entry, user: user, created_at: ReviewsQuery::NewReviewBubbleInterval.ago),
        create(:review, target: entry, user: user)
      ]
    end
  end

  describe 'fetch' do
    describe 'with_id' do
      subject { ReviewsQuery.new(entry, entry, @reviews[0].id).fetch.to_a }

      it 'has 1 item' do
        expect(subject.size).to eq(1)
      end
      its(:first) { should eq @reviews[0] }
    end

    describe 'without_id' do
      subject { ReviewsQuery.new(entry, entry).fetch }

      it 'has 3 items' do
        expect(subject.size).to eq(3)
      end
      its(:last) { should eq @reviews[1] }
      its(:first) { should eq @reviews[2] }
    end
  end
end
