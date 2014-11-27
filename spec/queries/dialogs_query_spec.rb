describe DialogsQuery do
  before { Message.antispam = false }

  let(:user) { create :user }
  let(:target_user) { create :user }
  let(:user_3) { create :user }
  let(:query) { DialogsQuery.new user }

  let!(:message_to_1) { create :message, from: target_user, to: user }
  let!(:message_from_1) { create :message, from: user, to: target_user }
  let!(:message_to_2) { create :message, from: user, to: user_3 }

  describe '#fetch' do
    subject(:fetch) { query.fetch 1, 1 }
    it { should have(2).items }

    context 'with ignores' do
      let(:user_4) { create :user }
      let!(:ignore_1) { create :ignore, user: user, target: user_3 }
      let!(:ignore_2) { create :ignore, user: user, target: user_4 }

      let!(:message_to_3) { create :message, from: user, to: user_4 }
      it { should have(1).item }

      describe 'dialog' do
        subject { fetch.first }
        its(:user) { should eq user }
        its(:message) { should eq message_from_1 }
      end
    end

    context 'deleted messages' do
      let!(:message_to_1) { create :message, from: target_user, to: user, dst_del: true }
      let!(:message_from_1) { create :message, from: user, to: target_user, src_del: true }
      it { should have(1).item }
    end
  end

  describe '#postload' do
    subject(:postload) { query.postload page, limit }

    context 'first page' do
      let(:page) { 1 }
      let(:limit) { 1 }

      its(:first) { should have(1).item }
      its(:second) { should be_truthy }

      describe 'dialog' do
        subject { postload.first.first }
        its(:user) { should eq user }
        its(:message) { should eq message_to_2 }
      end
    end

    context 'second page' do
      let(:page) { 2 }
      let(:limit) { 1 }

      its(:first) { should have(1).item }
      its(:second) { should be_falsy }

      describe 'dialog' do
        subject { postload.first.first }
        its(:user) { should eq user }
        its(:message) { should eq message_from_1 }
      end
    end

    context 'limit 2' do
      let(:page) { 1 }
      let(:limit) { 2 }

      its(:first) { should have(2).items }
      its(:second) { should be_falsy }

      describe 'first dialog' do
        subject { postload.first.first }
        its(:user) { should eq user }
        its(:message) { should eq message_to_2 }
      end

      describe 'second dialog' do
        subject { postload.first.second }
        its(:user) { should eq user }
        its(:message) { should eq message_from_1 }
      end
    end
  end
end
