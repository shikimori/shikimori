describe DialogsQuery do
  let(:target_user) { create :user }
  let(:user_3) { create :user }
  let(:query) { DialogsQuery.new user }

  let!(:message_to_1) { create :message, from: target_user, to: user }
  let!(:message_from_1) { create :message, from: user, to: target_user }
  let!(:message_to_2) { create :message, from: user, to: user_3 }

  describe '#fetch' do
    subject(:fetch) { query.fetch 1, 1 }
    it { is_expected.to have(2).items }

    context 'with ignores' do
      let(:user_4) { create :user }
      let!(:ignore_1) { create :ignore, user: user, target: user_3 }
      let!(:ignore_2) { create :ignore, user: user, target: user_4 }

      let!(:message_to_3) { create :message, from: user, to: user_4 }
      it { is_expected.to have(1).item }

      describe 'dialog' do
        subject { fetch.first }
        its(:user) { is_expected.to eq user }
        its(:message) { is_expected.to eq message_from_1 }
      end
    end

    context 'deleted messages' do
      let!(:message_to_1) { create :message, from: target_user, to: user, is_deleted_by_to: true }
      it { is_expected.to have(2).items }
    end
  end

  describe '#postload' do
    subject(:postload) { query.postload page, limit }

    context 'first page' do
      let(:page) { 1 }
      let(:limit) { 1 }

      its(:first) { is_expected.to have(1).item }
      its(:second) { is_expected.to eq true }

      describe 'dialog' do
        subject { postload.first.first }
        its(:user) { is_expected.to eq user }
        its(:message) { is_expected.to eq message_to_2 }
      end
    end

    context 'second page' do
      let(:page) { 2 }
      let(:limit) { 1 }

      its(:first) { is_expected.to have(1).item }
      its(:second) { is_expected.to eq false }

      describe 'dialog' do
        subject { postload.first.first }
        its(:user) { is_expected.to eq user }
        its(:message) { is_expected.to eq message_from_1 }
      end
    end

    context 'limit 2' do
      let(:page) { 1 }
      let(:limit) { 2 }

      its(:first) { is_expected.to have(2).items }
      its(:second) { is_expected.to eq false }

      describe 'first dialog' do
        subject { postload.first.first }
        its(:user) { is_expected.to eq user }
        its(:message) { is_expected.to eq message_to_2 }
      end

      describe 'second dialog' do
        subject { postload.first.second }
        its(:user) { is_expected.to eq user }
        its(:message) { is_expected.to eq message_from_1 }
      end
    end
  end
end
