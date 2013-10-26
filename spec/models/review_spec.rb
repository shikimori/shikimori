
require 'spec_helper'

describe Review do
  context :relations do
    it { should belong_to :target }
    it { should belong_to :user }
    it { should belong_to :approver }
    it { should have_one :thread }
  end

  context :validations do
    it { should validate_presence_of :user }
    it { should validate_presence_of :target }

    context :accepted do
      subject { build :review, state: 'accepted' }
      it { should validate_presence_of :approver }
    end

    context :rejected do
      subject { build :review, state: 'rejected' }
      it { should validate_presence_of :approver }
    end
  end

  context :scopes do
    describe :pending do
      subject { Review.pending }
      let!(:review1) { create :review, state: :pending }
      let!(:review2) { create :review, state: :accepted }
      it { should eq [review1] }
    end

    describe :visible do
      subject { Review.visible }
      let!(:review1) { create :review, state: :pending }
      let!(:review2) { create :review, state: :accepted }
      let!(:review3) { create :review, state: :rejected }
      it { should eq [review1, review2] }
    end
  end

  context :hooks do
    it 'creates thread' do
      expect {
        create :review, target: create(:anime)
      }.to change(ReviewComment, :count).by 1
    end
  end

  context :state_machine do
    let(:user) { create :user }
    subject(:review) { create :review, user: user }

    describe :accept do
      before { review.accept user }
      its(:approver) { should eq user }
    end

    describe :reject do
      before { review.reject user }
      its(:approver) { should eq user }
    end
  end

  context :instance_methods do
    let(:user) { build_stubbed :user }
    let(:review) { create :review, user: user }

    describe :to_offtopic! do
      before { review.reject! user }
      it { review.thread.section_id.should eq Section::OfftopicId }
    end
  end
end
