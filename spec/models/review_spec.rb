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
      subject { build :review, state: 'accepted' }
      it { is_expected.to validate_presence_of :approver }
    end

    context 'rejected' do
      subject { build :review, state: 'rejected' }
      it { is_expected.to validate_presence_of :approver }
    end
  end

  context 'scopes' do
    let(:user) { seed :user }

    describe 'pending' do
      subject { Review.pending }
      let!(:review1) { create :review, state: :pending }
      let!(:review2) { create :review, state: :accepted,
        user: build_stubbed(:user), approver: user }
      it { is_expected.to eq [review1] }
    end

    describe 'visible' do
      subject { Review.visible.order(:id) }
      let!(:review1) { create :review, state: :pending }
      let!(:review2) { create :review, state: :accepted,
        user: build_stubbed(:user), approver: user }
      let!(:review3) { create :review, state: :rejected,
        user: build_stubbed(:user), approver: user }
      it { is_expected.to eq [review1, review2] }
    end
  end

  context 'state_machine' do
    let(:user) { create :user }
    subject(:review) { create :review, :with_topics, user: user }

    describe 'accept' do
      before { review.accept user }
      its(:approver) { is_expected.to eq user }
    end

    describe 'reject' do
      before { review.reject user }
      its(:approver) { is_expected.to eq user }
    end
  end

  describe 'instance methods' do
    let(:user) { create :user }
    let(:review) { create :review, :with_topics, user: user }

    describe '#to_offtopic' do
      before { review.reject! user }
      it { expect(review.topic.forum_id).to eq Forum::OFFTOPIC_ID }
    end
  end

  describe 'permissions' do
    let(:review) { build_stubbed :review }
    let(:user) { build_stubbed :user, :user, :day_registered }
    subject { Ability.new user }

    context 'review owner' do
      let(:review) { build_stubbed :review, user: user }

      context 'not banned' do
        it { is_expected.to be_able_to :manage, review }
      end

      context 'newly registered' do
        let(:user) { build_stubbed :user, :user, created_at: 23.hours.ago }
        it { is_expected.not_to be_able_to :manage, review }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :banned }
        it { is_expected.not_to be_able_to :manage, review }
      end
    end

    context 'reviews moderator' do
      let(:user) { build_stubbed :user, :reviews_moderator }
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

  describe 'topics concern' do
    describe 'associations' do
      it { is_expected.to have_many :topics }
    end

    describe 'callbacks' do
      let(:model) { build :review }

      before { allow(model).to receive(:generate_topics) }
      before { model.save }

      describe '#generate_topics' do
        it { expect(model).to have_received :generate_topics }
      end
    end

    describe 'instance methods' do
      let(:model) { build_stubbed :review }

      describe '#generate_topics' do
        let(:topics) { model.topics.order(:locale) }
        before { model.generate_topics }

        it do
          expect(topics).to have(1).item
          expect(topics.first.locale).to eq model.locale
        end
      end

      describe '#topic_auto_generated' do
        it { expect(model.topic_auto_generated?).to eq true }
      end

      describe '#topic_user' do
        it { expect(model.topic_user).to eq model.user }
      end

      describe '#topic' do
        it { expect(model.topic).to eq model.topics.first }
      end
    end
  end
end
