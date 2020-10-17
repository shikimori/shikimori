describe BbCodes::Quotes::QuoteableToBbcode do
  subject { described_class.instance.call meta }

  context 'qwe' do
    let(:meta) do
      {
        nickname: 'qwe'
      }
    end
    it { is_expected.to eq '[user]qwe[/user]' }
  end

  context 'c1;2;qwe' do
    let(:meta) do
      {
        comment_id: 1,
        user_id: 2,
        nickname: 'rty'
      }
    end
    it do
      is_expected.to eq(
        "[comment=#{meta[:comment_id]} quote=2]#{meta[:nickname]}[/comment]"
      )
    end
  end

  context 'm1;2;qwe' do
    let(:meta) do
      {
        message_id: 1,
        user_id: 2,
        nickname: 'yui'
      }
    end
    it do
      is_expected.to eq(
        "[message=#{meta[:message_id]} quote=2]#{meta[:nickname]}[/message]"
      )
    end
  end

  context 't1;2;qwe' do
    let(:meta) do
      {
        topic_id: 1,
        user_id: 2,
        nickname: 'zxc'
      }
    end
    it do
      is_expected.to eq(
        "[topic=#{meta[:topic_id]} quote=2]#{meta[:nickname]}[/topic]"
      )
    end
  end
end
