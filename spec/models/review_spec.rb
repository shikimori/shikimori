# frozen_string_literal: true

describe Review do
  describe 'relations' do
    it { is_expected.to belong_to :target }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :approver }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :target }
    it { is_expected.to validate_presence_of :locale }

    context 'accepted' do
      subject { build :review, :accepted }
      it { is_expected.to validate_presence_of :approver }
    end

    context 'rejected' do
      subject { build :review, :rejected }
      it { is_expected.to validate_presence_of :approver }
    end
  end

  context 'scopes' do
    let(:user) { seed :user }

    describe 'pending' do
      subject { Review.pending }
      let!(:review1) { create :review, :pending }
      let!(:review2) do
        create :review, :accepted, user: build_stubbed(:user), approver: user
      end
      it { is_expected.to eq [review1] }
    end

    describe 'visible' do
      subject { Review.visible.order(:id) }
      let!(:review1) { create :review, :pending }
      let!(:review2) do
        create :review, :accepted, user: build_stubbed(:user), approver: user
      end
      let!(:review3) do
        create :review, :rejected, user: build_stubbed(:user), approver: user
      end
      it { is_expected.to eq [review1, review2] }
    end
  end

  describe 'permissions' do
    let(:review) { build_stubbed :review }
    let(:user) { build_stubbed :user, :user, :week_registered }
    subject { Ability.new user }

    context 'review owner' do
      let(:review) { build_stubbed :review, user: user }

      context 'not banned' do
        it { is_expected.to be_able_to :manage, review }
      end

      context 'newly registered' do
        let(:user) { build_stubbed :user, :user }
        it { is_expected.not_to be_able_to :manage, review }
      end

      context 'day registered' do
        let(:user) { build_stubbed :user, :user, :day_registered }
        it { is_expected.not_to be_able_to :manage, review }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :banned }
        it { is_expected.not_to be_able_to :manage, review }
      end
    end

    context 'reviews moderator' do
      let(:user) { build_stubbed :user, :review_moderator }
      it { is_expected.to be_able_to :manage, review }
    end

    context 'forum moderator' do
      let(:user) { build_stubbed :user, :moderator }
      it { is_expected.to be_able_to :manage, review }
    end

    context 'user' do
      it { is_expected.to be_able_to :read, review }
      it { is_expected.not_to be_able_to :new, review }
      it { is_expected.not_to be_able_to :edit, review }
      it { is_expected.not_to be_able_to :destroy, review }
    end

    context 'guest' do
      let(:user) { nil }

      it { is_expected.to be_able_to :read, review }
      it { is_expected.not_to be_able_to :new, review }
      it { is_expected.not_to be_able_to :edit, review }
      it { is_expected.not_to be_able_to :destroy, review }
    end
  end

  it_behaves_like :topics_concern, :review
  it_behaves_like :moderatable_concern, :review
end
