describe FayeService do
  let(:service) { FayeService.new user, faye }

  let(:faye) { 'test' }
  let(:topic) { create :topic, user: user }
  let!(:publisher) { FayePublisher.new user, faye }

  describe '#create' do
    let(:trackable) { build :comment, commentable: topic, body: body }
    subject(:act) { service.create trackable }

    context 'success' do
      before do
        expect(FayePublisher)
          .to receive(:new)
          .with(user, faye)
          .and_return publisher
        expect_any_instance_of(FayePublisher)
          .to receive(:publish)
          .with an_instance_of(trackable.class), :created
      end
      let(:body) { 'test' }

      it { is_expected.to be true }
      describe 'trackable' do
        before { act }
        it { expect(trackable).to be_persisted }
      end
    end

    context 'failure' do
      before { expect_any_instance_of(FayePublisher).not_to receive :publish }
      let(:body) { nil }

      it { is_expected.to be false }
      describe 'trackable' do
        before { act }
        it { expect(trackable).to be_new_record }
      end
    end
  end

  describe '#create!' do
    let(:trackable) { build :comment, commentable: topic, body: body }
    subject(:act) { service.create! trackable }

    context 'success' do
      before do
        expect(FayePublisher)
          .to receive(:new)
          .with(user, faye)
          .and_return publisher
        expect_any_instance_of(FayePublisher)
          .to receive(:publish)
          .with an_instance_of(trackable.class), :created
      end
      let(:body) { 'test' }

      it { is_expected.to be_nil }

      describe 'trackable' do
        before { act }
        it { expect(trackable).to be_persisted }
      end
    end

    context 'failure' do
      before { expect_any_instance_of(FayePublisher).not_to receive :publish }
      let(:body) { nil }

      it { expect { act }.to raise_error ActiveRecord::RecordInvalid }
    end
  end

  describe '#update' do
    let(:params) { { body: body } }
    let(:trackable) { create :comment, user: user }
    subject(:act) { service.update trackable, params }

    context 'success' do
      before do
        expect(FayePublisher)
          .to receive(:new)
          .with(user, faye)
          .and_return publisher
        expect_any_instance_of(FayePublisher)
          .to receive(:publish)
          .with an_instance_of(trackable.class), :updated
      end
      let(:body) { 'test' }

      it { is_expected.to be true }

      describe 'trackable' do
        before { act }
        it { expect(trackable).to be_valid }
      end
    end

    context 'failure' do
      before { expect_any_instance_of(FayePublisher).not_to receive :publish }
      let(:body) { nil }

      it { is_expected.to be false }

      describe 'trackable' do
        before { act }
        it { expect(trackable).to_not be_valid }
      end
    end
  end

  describe '#destroy' do
    subject { service.destroy trackable }

    context 'comment' do
      before do
        expect(FayePublisher)
          .to receive(:new)
          .with(user, faye)
          .and_return publisher
        expect_any_instance_of(FayePublisher)
          .to receive(:publish)
          .with an_instance_of(trackable.class), :deleted
      end
      let(:trackable) { create :comment, user: user }
      it { is_expected.to_not be_persisted }
    end

    context 'message' do
      before { expect(FayePublisher).to_not receive :new }

      context 'private' do
        let(:trackable) { create :message, :private, to: user, from: user_2 }

        it { is_expected.to be_persisted }
        its(:is_deleted_by_to) { is_expected.to eq true }
      end

      context 'notification' do
        let(:trackable) { create :message, :notification, to: user }
        it { is_expected.to_not be_persisted }
      end
    end
  end

  describe '#offtopic' do
    subject(:act) { service.offtopic comment, is_offtopic }

    let(:comment) { create :comment, commentable: topic, is_offtopic: !is_offtopic }
    let(:is_offtopic) { true }

    let(:publisher) { double publish_marks: nil }
    before do
      allow(FayePublisher)
        .to receive(:new)
        .with(user, faye)
        .and_return publisher
    end

    before { act }

    it do
      is_expected.to eq [comment.id]
      expect(publisher)
        .to have_received(:publish_marks)
        .with [comment.id], 'offtopic', is_offtopic
    end

    describe 'comment' do
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

  describe '#summary' do
    subject(:act) { service.summary comment, is_summary }

    let(:comment) { create :comment, commentable: topic, is_summary: !is_summary }
    let(:is_summary) { true }

    let(:publisher) { double publish_marks: nil }
    before do
      allow(FayePublisher)
        .to receive(:new)
        .with(user, faye)
        .and_return publisher
    end

    before { act }

    it do
      is_expected.to eq [comment.id]
      expect(publisher)
        .to have_received(:publish_marks)
        .with [comment.id], 'summary', is_summary
    end

    describe 'comment' do
      context 'summary' do
        let(:is_summary) { true }
        it { expect(comment).to be_summary }
      end

      context 'not summary' do
        let(:is_summary) { false }
        it { expect(comment).to_not be_summary }
      end
    end
  end

  describe '#set_replies' do
    let(:comment) { create :comment, commentable: topic, user: user }
    let(:replied_comment) { create :comment, commentable: topic, user: user }

    before do
      expect(FayePublisher)
        .to receive(:new)
        .with(user, faye)
        .and_return publisher
    end
    after { service.set_replies comment }

    it do
      expect_any_instance_of(FayePublisher)
        .to receive(:publish_replies)
        .with comment, anything
    end
  end
end
