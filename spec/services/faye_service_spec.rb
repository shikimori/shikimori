describe FayeService do
  let(:service) { FayeService.new user, faye }

  let(:faye) { 'test' }
  let(:topic) { create :topic, user: user }
  let!(:publisher) { FayePublisher.new user, faye }

  before do
    allow(FayePublisher)
      .to receive(:new)
      .with(user, faye)
      .and_return publisher
  end

  describe '#create' do
    let(:trackable) { build :comment, commentable: topic, body: body }
    subject(:act) { service.create trackable }

    context 'success' do
      before do
        expect(publisher)
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
      before { expect(publisher).not_to receive :publish }
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
        expect(publisher)
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
      before { expect(publisher).not_to receive :publish }
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
        expect(publisher)
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
      before { expect(publisher).not_to receive :publish }
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
        expect(publisher)
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

  describe '#convert_review' do
    subject(:act) { service.convert_review forum_entry, is_convert_to_review }

    before do
      allow(Comment::ConvertToReview).to receive(:call).and_call_original
      allow(Review::ConvertToComment).to receive(:call).and_call_original

      if (forum_entry.is_a?(Comment) && is_convert_to_review) ||
          (forum_entry.is_a?(Review) && !is_convert_to_review)
        expect(publisher)
          .to receive(:publish_conversion)
          .with forum_entry, anything, anything
      else
        expect(publisher).to_not receive :publish_conversion
      end
    end

    let!(:anime_topic) { create :anime_topic, linked: anime }
    let(:anime) { create :anime }

    context 'comment' do
      let(:forum_entry) { create :comment, commentable: anime_topic }

      context 'is_convert_to_review' do
        let(:is_convert_to_review) { true }

        it do
          is_expected.to be_kind_of Review
          is_expected.to be_persisted
          expect(Comment::ConvertToReview)
            .to have_received(:call)
            .with(forum_entry)
          expect(Review::ConvertToComment).to_not have_received :call
        end
      end

      context '!is_convert_to_review' do
        let(:is_convert_to_review) { false }

        it do
          is_expected.to be_nil
          expect(Comment::ConvertToReview).to_not have_received :call
          expect(Review::ConvertToComment).to_not have_received :call
        end
      end
    end

    context 'review' do
      let(:forum_entry) { create :review, anime: anime }

      context '!is_convert_to_review' do
        let(:is_convert_to_review) { false }

        it do
          is_expected.to be_kind_of Comment
          is_expected.to be_persisted
          expect(Review::ConvertToComment)
            .to have_received(:call)
            .with(forum_entry)
          expect(Comment::ConvertToReview).to_not have_received :call
        end
      end

      context 'is_convert_to_review' do
        let(:is_convert_to_review) { true }

        it do
          is_expected.to be_nil
          expect(Comment::ConvertToReview).to_not have_received :call
          expect(Review::ConvertToComment).to_not have_received :call
        end
      end
    end
  end

  describe '#set_replies' do
    let(:comment) { create :comment, commentable: topic, user: user }
    let(:replied_comment) { create :comment, commentable: topic, user: user }

    after { service.set_replies comment }

    it do
      expect(publisher)
        .to receive(:publish_replies)
        .with comment, anything
    end
  end
end
