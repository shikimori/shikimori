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
