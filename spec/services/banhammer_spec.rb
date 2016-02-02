describe Banhammer do
  let(:banhammer) { Banhammer.instance }
  let(:comment) { build_stubbed :comment, user: user, body: text, commentable: build_stubbed(:topic, user: user) }
  let(:text) { 'хуй' }
  let(:user) { build_stubbed :user }

  describe '#release' do
    let(:user) { create :user, :banhammer }
    let(:comment) { create :comment, user: user, body: text }
    subject { banhammer.release! comment }

    context 'not abusive' do
      let(:text) { 'test' }
      it { is_expected.to be_nil }
    end

    context 'abusive' do
      it { is_expected.to be_kind_of Ban }
    end
  end

  describe '#censor' do
    it { expect(banhammer.censor 'test хуй').to eq 'test xxx' }
  end

  describe '#ban' do
    let!(:user_banhammer) { create :user, :banhammer }
    let(:comment) { create :comment, body: text }
    let(:text) { 'test хуй test хуй' }
    subject(:ban) { banhammer.send :ban, comment }

    it do
      expect(ban).to be_kind_of Ban
      expect(ban).to have_attributes(user_id: comment.user.id, comment_id: comment.id, moderator_id: user_banhammer.id)
      expect(ban.duration).to eql BanDuration.new('30m')
      expect(comment.body).to eq "test [color=#ff4136]###[/color] test [color=#ff4136]###[/color]\n\n[ban=#{ban.id}]"
    end
  end

  describe '#abusive?' do
    it { expect(banhammer.abusive? 'х*о').to be_falsy }
    it { expect(banhammer.abusive? 'тест').to be_falsy }
    it { expect(banhammer.abusive? '!!!').to be_falsy }
    it { expect(banhammer.abusive? '*!!!*').to be_falsy }
    it { expect(banhammer.abusive? 'N*O*K').to be_falsy }
    it { expect(banhammer.abusive? '^O^').to be_falsy }
    it { expect(banhammer.abusive? 'her').to be_falsy }
    it { expect(banhammer.abusive? 'на!').to be_falsy }

    it { expect(banhammer.abusive? 'http://shikimori.org/cosplay_galleries/publishing/хуй/test').to be_falsy }
    it { expect(banhammer.abusive? '[img]http://shikimori.org/cosplay_galleries/publishing/хуй/test.png[/img]').to be_falsy }
    it { expect(banhammer.abusive? '[poster]http://shikimori.org/cosplay_galleries/publishing/хуй/test.png[/poster]').to be_falsy }
    it { expect(banhammer.abusive? '###[/quote]').to be_falsy }
    it { expect(banhammer.abusive? '[character=17712]Yuzuki Eba[/character]').to be_falsy }

    it { expect(banhammer.abusive? 'хуй').to be_truthy }
    it { expect(banhammer.abusive? 'хуйня').to be_truthy }
    it { expect(banhammer.abusive? 'ху*').to be_truthy }
    it { expect(banhammer.abusive? 'х*й').to be_truthy }
    it { expect(banhammer.abusive? 'хуйло').to be_truthy }
    it { expect(banhammer.abusive? 'бля').to be_truthy }
    it { expect(banhammer.abusive? 'блять').to be_truthy }
    it { expect(banhammer.abusive? 'блядь').to be_truthy }
    it { expect(banhammer.abusive? 'нах').to be_truthy }
    it { expect(banhammer.abusive? 'пох').to be_truthy }
    it { expect(banhammer.abusive? 'охуел').to be_truthy }
    it { expect(banhammer.abusive? 'оху*ть').to be_truthy }
    it { expect(banhammer.abusive? 'похер').to be_truthy }
    it { expect(banhammer.abusive? 'нахер').to be_truthy }
    it { expect(banhammer.abusive? 'херня').to be_truthy }
    it { expect(banhammer.abusive? 'хера').to be_truthy }
    it { expect(banhammer.abusive? 'херь').to be_truthy }
    it { expect(banhammer.abusive? 'сука').to be_truthy }
    it { expect(banhammer.abusive? 'с*ка').to be_truthy }
    it { expect(banhammer.abusive? 'су*а').to be_truthy }
    it { expect(banhammer.abusive? 'сучка').to be_truthy }
    it { expect(banhammer.abusive? 'сучёнок').to be_truthy }
    it { expect(banhammer.abusive? 'хер').to be_truthy }
    it { expect(banhammer.abusive? 'херо*о').to be_truthy }
    it { expect(banhammer.abusive? 'ебать').to be_truthy }
    it { expect(banhammer.abusive? 'ёба,').to be_truthy }
    it { expect(banhammer.abusive? 'заебись').to be_truthy }
    it { expect(banhammer.abusive? 'пизда').to be_truthy }
    it { expect(banhammer.abusive? 'пиздуй').to be_truthy }
    it { expect(banhammer.abusive? 'пиздец').to be_truthy }
    it { expect(banhammer.abusive? 'н[size=15]а[/size]х').to be_truthy }
  end

  describe '#abusiveness' do
    subject { banhammer.send :abusiveness, text }

    context 'not abusive' do
      let(:text) { 'test' }
      it { is_expected.to eq 0 }
    end

    context 'abusive' do
      it { is_expected.to eq 1 }
    end

    context 'abusive thrice' do
      let(:text) { 'хуй бля нахер' }
      it { is_expected.to eq 3 }
    end
  end

  describe '#ban_duration' do
    subject { banhammer.send :ban_duration, comment }

    context 'had no bans' do
      it { is_expected.to eq '15m' }
    end

    context 'had no bans double abusiveness' do
      let(:text) { 'хуй хуй' }
      it { is_expected.to eq '30m' }
    end

    context 'had bans less than 1.5 days ago' do
      let(:user) { build_stubbed :user, bans: [build_stubbed(:ban, created_at: 1.day.ago), build_stubbed(:ban, created_at: 1.day.ago)] }
      it { is_expected.to eq '1d' }
    end

    context 'had bans more than 1.5 days ago' do
      let(:user) { build_stubbed :user, bans: [build_stubbed(:ban, created_at: 2.days.ago), build_stubbed(:ban, created_at: 2.days.ago)] }
      it { is_expected.to eq '2h' }
    end
  end
end
