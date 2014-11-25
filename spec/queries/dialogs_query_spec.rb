describe DialogsQuery do
  before { Message.antispam = false }

  let(:user) { create :user }
  let(:user_2) { create :user }
  let(:user_3) { create :user }
  let(:query) { DialogsQuery.new user }

  let!(:message_to_1) { create :message, from: user_2, to: user }
  let!(:message_from_1) { create :message, from: user, to: user_2 }
  let!(:message_to_2) { create :message, from: user, to: user_3 }

  describe '#fetch' do
    subject { query.fetch 1, 1 }
    it { should eq [message_to_2, message_from_1] }

    context 'with ignores' do
      let(:user_4) { create :user }
      let!(:ignore_1) { create :ignore, user: user, target: user_3 }
      let!(:ignore_2) { create :ignore, user: user, target: user_4 }

      let!(:message_to_3) { create :message, from: user, to: user_4 }
      it { should eq [message_from_1] }
    end
  end

  describe '#postload' do
    subject { query.postload page, limit }

    context 'first page' do
      let(:page) { 1 }
      let(:limit) { 1 }

      its(:first) { should eq [message_to_2] }
      its(:second) { should be_truthy }
    end

    context 'second page' do
      let(:page) { 2 }
      let(:limit) { 1 }

      its(:first) { should eq [message_from_1] }
      its(:second) { should be_falsy }
    end

    context 'limit 2' do
      let(:page) { 1 }
      let(:limit) { 2 }

      its(:first) { should eq [message_to_2, message_from_1] }
      its(:second) { should be_falsy }
    end
  end
end
