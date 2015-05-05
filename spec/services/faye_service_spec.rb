describe FayeService do
  let(:service) { FayeService.new user, faye }

  let(:faye) { 'test' }
  let(:user) { create :user }
  let(:topic) { create :entry, user: user }
  let!(:publisher) { FayePublisher.new user, faye }

  describe '#create' do
    let(:trackable) { build :comment, commentable: topic, body: body }
    subject(:act) { service.create trackable }

    context 'success' do
      before { expect(FayePublisher).to receive(:new).with(user, faye).and_return publisher }
      before { expect_any_instance_of(FayePublisher).to receive(:publish).with an_instance_of(trackable.class), :created }
      let(:body) { 'test' }

      it { should be true }
      describe 'trackable' do
        before { act }
        it { expect(trackable).to be_persisted }
      end
    end

    context 'failure' do
      before { expect_any_instance_of(FayePublisher).not_to receive :publish }
      let(:body) { nil }

      it { should be false }
      describe 'trackable' do
        before { act }
        it { expect(trackable).to be_new_record }
      end
    end
  end

  describe '#update' do
    let(:params) {{ body: body }}
    let(:trackable) { create :comment, user: user }
    subject(:act) { service.update trackable, params }

    context 'success' do
      before { expect(FayePublisher).to receive(:new).with(user, faye).and_return publisher }
      before { expect_any_instance_of(FayePublisher).to receive(:publish).with an_instance_of(trackable.class), :updated }
      let(:body) { 'test' }

      it { should be true }
      describe 'trackable' do
        before { act }
        it { expect(trackable).to be_valid }
      end
    end

    context 'failure' do
      before { expect_any_instance_of(FayePublisher).not_to receive :publish }
      let(:body) { nil }

      it { should be false }
      describe 'trackable' do
        before { act }
        it { expect(trackable).to_not be_valid }
      end
    end
  end

  describe '#destroy' do
    subject { service.destroy trackable }

    context 'comment' do
      before { expect(FayePublisher).to receive(:new).with(user, faye).and_return publisher }
      before { expect_any_instance_of(FayePublisher).to receive(:publish).with an_instance_of(trackable.class), :deleted }
      let(:trackable) { create :comment, user: user }
      it { should_not be_persisted }
    end

    context 'message' do
      before { expect(FayePublisher).to_not receive :new }

      context 'private' do
        let(:trackable) { create :message, :private, to: user }

        it { should be_persisted }
        its(:is_deleted_by_to) { should be_truthy }
      end

      context 'notification' do
        let(:trackable) { create :message, :notification, to: user }
        it { should_not be_persisted }
      end
    end
  end

  describe '#offtopic' do
    let(:comment) { create :comment, commentable: topic, offtopic: !is_offtopic }
    subject(:act) { service.offtopic comment, is_offtopic }
    let(:is_offtopic) { true }

    before { expect(FayePublisher).to receive(:new).with(user, faye).and_return publisher }
    before { expect_any_instance_of(FayePublisher).to receive(:publish_marks).with [comment.id], 'offtopic', is_offtopic }

    it { should eq [comment.id] }

    describe 'comment' do
      before { act }

      context 'offtopic' do
        let(:is_offtopic) { true }
        it { expect(comment).to be_offtopic }
      end

      context 'not offtopic' do
        let(:is_offtopic) { false }
        it { expect(comment).to_not be_offtopic }
      end
    end
  end

  describe '#review' do
    let(:comment) { create :comment, commentable: topic, review: !is_review }
    subject(:act) { service.review comment, is_review }
    let(:is_review) { true }

    before { expect(FayePublisher).to receive(:new).with(user, faye).and_return publisher }
    before { expect_any_instance_of(FayePublisher).to receive(:publish_marks).with [comment.id], 'review', is_review }

    it { should eq [comment.id] }

    describe 'comment' do
      before { act }

      context 'review' do
        let(:is_review) { true }
        it { expect(comment).to be_review }
      end

      context 'not review' do
        let(:is_review) { false }
        it { expect(comment).to_not be_review }
      end
    end
  end

  describe '#set_replies' do
    let(:comment) { create :comment, commentable: topic, user: user }
    let(:replied_comment) { create :comment, commentable: topic, user: user }

    before { expect(FayePublisher).to receive(:new).with(user, faye).and_return publisher }
    after { service.set_replies comment }

    it { expect_any_instance_of(FayePublisher).to receive(:publish_replies).with comment, anything }
  end
end
