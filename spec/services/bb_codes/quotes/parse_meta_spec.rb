describe BbCodes::Quotes::ParseMeta do
  subject { described_class.call text }

  context 'empty line' do
    let(:text) { ['', nil].sample }
    it { is_expected.to be nil }
  end

  context 'qwe' do
    let(:text) { 'qwe' }
    it { is_expected.to eq nickname: 'qwe' }
  end

  context 'c1;1;qwe' do
    let(:text) { 'c1;1;qwe' }
    it do
      is_expected.to eq(
        comment_id: 1,
        user_id: 1,
        nickname: 'qwe'
      )
    end
  end

  context 'm1;1;qwe' do
    let(:text) { 'm1;1;qwe' }
    it do
      is_expected.to eq(
        message_id: 1,
        user_id: 1,
        nickname: 'qwe'
      )
    end
  end

  context 't1;1;qwe' do
    let(:text) { 't1;1;qwe' }
    it do
      is_expected.to eq(
        topic_id: 1,
        user_id: 1,
        nickname: 'qwe'
      )
    end
  end

  context 'zxc;1;qwe' do
    let(:text) { 'zxc;1;qwe' }
    it { is_expected.to be nil }
  end
end
