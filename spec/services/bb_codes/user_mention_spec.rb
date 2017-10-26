describe BbCodes::UserMention do
  let!(:user) { create :user, nickname: 'test' }

  subject! { described_class.call text }

  describe 'just mention' do
    let(:text) { '@test, hello' }
    it do
      is_expected.to eq(
        "[mention=#{user.id}]#{user.nickname}[/mention], hello"
      )
    end
  end

  describe 'mention with period' do
    let(:text) { '@test.' }
    it { is_expected.to eq "[mention=#{user.id}]#{user.nickname}[/mention]." }
  end

  describe 'mention w/o comma' do
    let(:text) { '@test test test' }
    it do
      is_expected.to eq(
        "[mention=#{user.id}]#{user.nickname}[/mention] test test"
      )
    end
  end

  describe 'two mentions' do
    let(:text) { '@test, @test' }
    it do
      is_expected.to eq(
        "[mention=#{user.id}]#{user.nickname}[/mention], " \
          "[mention=#{user.id}]#{user.nickname}[/mention]"
      )
    end
  end
end
