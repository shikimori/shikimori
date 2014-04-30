require 'spec_helper'

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

  describe :fetch do
    describe :with_id do
      subject { ReviewsQuery.new(entry, entry, @reviews[0].id).fetch.to_a }

      it { should have(1).item  }
      its(:first) { should eq @reviews[0] }
    end

    describe :without_id do
      subject { ReviewsQuery.new(entry, entry).fetch }

      it { should have(3).items  }
      its(:last) { should eq @reviews[1] }
      its(:first) { should eq @reviews[2] }
    end
  end
end
