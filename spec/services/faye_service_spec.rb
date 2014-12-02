describe FayeService do
  let(:service) { FayeService.new user, faye }

  let(:faye) { 'test' }
  let(:user) { create :user }
  let(:topic) { create :entry, user: user }
  let!(:publisher) { FayePublisher.new user, faye }

  describe 'create' do
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

  describe 'update' do
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

  describe 'destroy' do
    let(:trackable) { create :comment, user: user }
    subject { service.destroy trackable }

    before { expect(FayePublisher).to receive(:new).with(user, faye).and_return publisher }
    before { expect_any_instance_of(FayePublisher).to receive(:publish).with an_instance_of(trackable.class), :deleted }

    it { should_not be_persisted }
  end
end
