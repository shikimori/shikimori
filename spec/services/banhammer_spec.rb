describe Banhammer do
  let(:banhammer) { Banhammer.new comment }
  let(:comment) { build_stubbed :comment, user: user, body: text, commentable: build_stubbed(:topic, user: user) }
  let(:text) { 'хуй' }
  let(:user) { build_stubbed :user }

  describe '#release' do
    let(:user) { create :user, :banhammer }
    let(:comment) { create :comment, user: user, body: text }
    subject { banhammer.release }

    context 'not abusive' do
      let(:text) { 'test' }
      it { should be_nil }
    end

    context 'abusive' do
      it { should be_kind_of Ban }
    end
  end

  describe '#ban' do
    let!(:user_banhammer) { create :user, :banhammer }
    let(:comment) { create :comment, body: text }
    let(:text) { 'test хуй test' }
    subject(:ban) { banhammer.send :ban }

    it do
      expect(ban).to be_kind_of Ban
      expect(ban).to have_attributes(user_id: comment.user.id, comment_id: comment.id, moderator_id: user_banhammer.id)
      expect(ban.duration).to eql BanDuration.new('15m')
      expect(comment.body).to eq "test [color=#ff4136]###[/color] test\n\n[ban=#{ban.id}]"
    end
  end

  describe '#abusive?',:focus do
    it { expect(banhammer.abusive? 'х*о').to be_falsy }
    it { expect(banhammer.abusive? 'тест').to be_falsy }
    it { expect(banhammer.abusive? '!!!').to be_falsy }
    it { expect(banhammer.abusive? '*!!!*').to be_falsy }

    it { expect(banhammer.abusive? 'хуй').to be_truthy }
    it { expect(banhammer.abusive? 'ху*').to be_truthy }
    it { expect(banhammer.abusive? 'х*й').to be_truthy }
    it { expect(banhammer.abusive? 'хуйло').to be_truthy }
    it { expect(banhammer.abusive? 'бля').to be_truthy }
    it { expect(banhammer.abusive? 'нах').to be_truthy }
    it { expect(banhammer.abusive? 'пох').to be_truthy }
    it { expect(banhammer.abusive? 'охуел').to be_truthy }
    it { expect(banhammer.abusive? 'оху*ть').to be_truthy }
    it { expect(banhammer.abusive? 'похер').to be_truthy }
    it { expect(banhammer.abusive? 'нахер').to be_truthy }
    it { expect(banhammer.abusive? 'сука').to be_truthy }
    it { expect(banhammer.abusive? 'с*ка').to be_truthy }
    it { expect(banhammer.abusive? 'су*а').to be_truthy }
    it { expect(banhammer.abusive? 'сучка').to be_truthy }
    it { expect(banhammer.abusive? 'хер').to be_truthy }
    it { expect(banhammer.abusive? 'херо*о').to be_truthy }
    it { expect(banhammer.abusive? 'ебать').to be_truthy }
    it { expect(banhammer.abusive? 'заебись').to be_truthy }
  end

  describe '#abusiveness' do
    subject { banhammer.send :abusiveness }

    context 'not abusive' do
      let(:text) { 'test' }
      it { should eq 0 }
    end

    context 'abusive' do
      it { should eq 1 }
    end

    context 'abusive thrice' do
      let(:text) { 'хуй бля нахер' }
      it { should eq 3 }
    end
  end

  describe '#ban_duration' do
    subject { banhammer.send :ban_duration }

    context 'had no bans' do
      it { should eq '15m' }
    end

    context 'had no bans double abusiveness' do
      let(:text) { 'хуй хуй' }
      it { should eq '30m' }
    end

    context 'had bans' do
      let(:user) { build_stubbed :user, bans: [build_stubbed(:ban)] }
      it { should eq '2h' }
    end
  end
end
