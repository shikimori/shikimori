describe CommentsService do
  let(:service) { CommentsService.new user, faye }

  let(:faye) { 'test' }
  let(:user) { create :user }
  let(:topic) { create :entry, user: user }
  let!(:publisher) { FayePublisher.new user, faye }

  describe :create do
    let(:params) {{
      commentable_id: topic.id,
      commentable_type: topic.class.name,
      body: body,
      offtopic: false,
      review: false
    }}
    subject { service.create params }

    context :success do
      before { FayePublisher.should_receive(:new).with(user, faye).and_return publisher }
      before { FayePublisher.any_instance.should_receive(:publish).with an_instance_of(Comment), :created }
      let(:body) { 'test' }

      it { should be_kind_of Comment }
      it { should be_persisted }
    end

    context :failure do
      before { FayePublisher.any_instance.should_not_receive :publish }
      let(:body) { nil }

      it { should be_kind_of Comment }
      it { should be_new_record }
    end
  end

  describe :update do
    let(:params) {{ body: body }}
    let(:comment) { create :comment, user: user }
    subject { service.update comment, params }

    context :forbidden do
      let(:service) { CommentsService.new create(:user), faye }
      let(:body) { 'test' }
      it { expect{subject}.to raise_error Forbidden }
    end

    context :success do
      before { FayePublisher.should_receive(:new).with(user, faye).and_return publisher }
      before { FayePublisher.any_instance.should_receive(:publish).with an_instance_of(Comment), :updated }
      let(:body) { 'test' }

      it { should be true }
    end

    context :failure do
      before { FayePublisher.any_instance.should_not_receive :publish }
      let(:body) { nil }

      it { should be false }
    end
  end

  describe :destroy do
    let(:comment) { create :comment, user: user }
    subject { service.destroy comment }

    context :forbidden do
      let(:service) { CommentsService.new create(:user), faye }
      it { expect{subject}.to raise_error Forbidden }
    end

    context :success do
      before { FayePublisher.should_receive(:new).with(user, faye).and_return publisher }
      before { FayePublisher.any_instance.should_receive(:publish).with an_instance_of(Comment), :deleted }

      it { should_not be_persisted }
    end
  end
end
