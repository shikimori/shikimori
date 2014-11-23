require 'cancan/matchers'

describe Review do
  describe 'relations' do
    it { should belong_to :target }
    it { should belong_to :user }
    it { should belong_to :approver }
    it { should have_one :thread }
  end

  describe 'validations' do
    it { should validate_presence_of :user }
    it { should validate_presence_of :target }

    context 'accepted' do
      subject { build :review, state: 'accepted' }
      it { should validate_presence_of :approver }
    end

    context 'rejected' do
      subject { build :review, state: 'rejected' }
      it { should validate_presence_of :approver }
    end
  end

  context 'scopes' do
    let(:user) { build_stubbed :user }

    describe 'pending' do
      subject { Review.pending }
      let!(:review1) { create :review, state: :pending }
      let!(:review2) { create :review, state: :accepted, approver: user }
      it { should eq [review1] }
    end

    describe 'visible' do
      subject { Review.visible }
      let!(:review1) { create :review, state: :pending }
      let!(:review2) { create :review, state: :accepted, approver: user }
      let!(:review3) { create :review, state: :rejected, approver: user }
      it { should eq [review1, review2] }
    end
  end

  context 'hooks' do
    it 'creates thread' do
      expect {
        create :review, target: create(:anime)
      }.to change(ReviewComment, :count).by 1
    end
  end

  context 'state_machine' do
    let(:user) { create :user }
    subject(:review) { create :review, user: user }

    describe 'accept' do
      before { review.accept user }
      its(:approver) { should eq user }
    end

    describe 'reject' do
      before { review.reject user }
      its(:approver) { should eq user }
    end
  end

  describe 'instance methods' do
    let(:user) { create :user }
    let(:review) { create :review, user: user }

    describe '#to_offtopic' do
      before { review.reject! user }
      it { expect(review.thread.section_id).to eq Section::OfftopicId }
    end
  end

  describe 'permissions' do
    let(:review) { build_stubbed :review }
    let(:user) { build_stubbed :user }
    subject { Ability.new user }

    context 'review owner' do
      let(:review) { build_stubbed :review, user: user }
      it { should be_able_to :manage, review }
    end

    context 'reviews moderator' do
      let(:user) { build_stubbed :user, :reviews_moderator }
      it { should be_able_to :manage, review }
    end

    context 'user' do
      it { should be_able_to :read, review }
      it { should_not be_able_to :new, review }
      it { should_not be_able_to :edit, review }
      it { should_not be_able_to :destroy, review }
    end

    context 'guest' do
      let(:user) { nil }
      it { should be_able_to :read, review }
      it { should_not be_able_to :new, review }
      it { should_not be_able_to :edit, review }
      it { should_not be_able_to :destroy, review }
    end
  end
end
