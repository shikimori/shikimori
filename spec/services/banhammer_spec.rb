describe Banhammer do
  let(:banhammer) { Banhammer.instance }
  let(:comment) do
    build_stubbed :comment,
      user: user,
      body: text,
      commentable: build_stubbed(:topic, user: user)
  end
  let(:text) { 'хуй' }
  let(:user) { build_stubbed :user }

  describe '#release!' do
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
    subject { banhammer.censor text, 'x' }

    let(:text) { 'test хуй' }
    it { is_expected.to eq 'test xxx' }

    context 'does not match ###' do
      let(:text) { '### test' }
      it { is_expected.to eq '### test' }
    end
  end

  describe '#ban', :focus do
    let!(:user_banhammer) { create :user, :banhammer }
    let(:comment) { create :comment, body: text }
    let(:text) { 'test хуй test хуй' }
    subject(:ban) { banhammer.send :ban, comment }

    it do
      expect(ban).to be_kind_of Ban
      expect(ban).to have_attributes(
        user_id: comment.user.id,
        comment_id: comment.id,
        moderator_id: user_banhammer.id
      )
      expect(ban.duration).to eql BanDuration.new('30m')
      expect(comment.body).to eq(
        "test [color=#ff4136]###[/color] test [color=#ff4136]###[/color]\n\n[ban=#{ban.id}]"
      )
    end

    context 'heavy abusiveness' do
      let(:text) { 'test хуй test хуй хуй хуй хуй хуй хуй хуй хуй хуй' }
      it do
        expect(ban.duration).to eql BanDuration.new('150m')
        expect(comment.body).to eq(
          "test ### test ### ### ### ### ### ### ### ### ###\n\n[ban=#{ban.id}]"
        )
      end
    end
  end

  describe '#abusive?' do
    it { expect(banhammer.abusive? '###').to eq false }
    it { expect(banhammer.abusive? 'BL!').to eq false }
    it { expect(banhammer.abusive? 'х*о').to eq false }
    it { expect(banhammer.abusive? 'тест').to eq false }
    it { expect(banhammer.abusive? '!!!').to eq false }
    it { expect(banhammer.abusive? '*!!!*').to eq false }
    it { expect(banhammer.abusive? 'N*O*K').to eq false }
    it { expect(banhammer.abusive? '^O^').to eq false }
    it { expect(banhammer.abusive? 'her').to eq false }
    it { expect(banhammer.abusive? 'на!').to eq false }

    it { expect(banhammer.abusive? '//shikimori.test/cosplay_galleries/publishing/хуй/test').to eq false }
    it { expect(banhammer.abusive? 'http://shikimori.test/cosplay_galleries/publishing/хуй/test').to eq false }
    it { expect(banhammer.abusive? '[img]//shikimori.test/cosplay_galleries/publishing/хуй/test.png[/img]').to eq false }
    it { expect(banhammer.abusive? '[poster]//shikimori.test/cosplay_galleries/publishing/хуй/test.png[/poster]').to eq false }
    it { expect(banhammer.abusive? '###[/quote]').to eq false }
    it { expect(banhammer.abusive? '[character=17712]Yuzuki Eba[/character]').to eq false }

    it { expect(banhammer.abusive? 'хуй').to eq true }
    it { expect(banhammer.abusive? 'хуйня').to eq true }
    it { expect(banhammer.abusive? 'похуй').to eq true }
    it { expect(banhammer.abusive? 'ху*').to eq true }
    it { expect(banhammer.abusive? 'х*й').to eq true }
    it { expect(banhammer.abusive? 'хуйло').to eq true }
    it { expect(banhammer.abusive? 'бля').to eq true }
    it { expect(banhammer.abusive? 'блять').to eq true }
    it { expect(banhammer.abusive? 'блядь').to eq true }
    it { expect(banhammer.abusive? 'нах').to eq true }
    it { expect(banhammer.abusive? 'пох').to eq true }
    it { expect(banhammer.abusive? 'охуел').to eq true }
    it { expect(banhammer.abusive? 'оху*ть').to eq true }
    it { expect(banhammer.abusive? 'похер').to eq true }
    it { expect(banhammer.abusive? 'нахер').to eq true }
    it { expect(banhammer.abusive? 'херня').to eq true }
    it { expect(banhammer.abusive? 'хера').to eq true }
    it { expect(banhammer.abusive? 'херь').to eq true }
    it { expect(banhammer.abusive? 'сука').to eq true }
    it { expect(banhammer.abusive? 'с*ка').to eq true }
    it { expect(banhammer.abusive? 'су*а').to eq true }
    it { expect(banhammer.abusive? 'сучка').to eq true }
    it { expect(banhammer.abusive? 'сучёнок').to eq true }
    it { expect(banhammer.abusive? 'хер').to eq true }
    it { expect(banhammer.abusive? 'херо*о').to eq true }
    it { expect(banhammer.abusive? 'ебать').to eq true }
    it { expect(banhammer.abusive? 'ёба,').to eq true }
    it { expect(banhammer.abusive? 'заебись').to eq true }
    it { expect(banhammer.abusive? 'пизда').to eq true }
    it { expect(banhammer.abusive? 'пиздуй').to eq true }
    it { expect(banhammer.abusive? 'пиздец').to eq true }
    it { expect(banhammer.abusive? 'н[size=15]а[/size]х').to eq true }
    it { expect(banhammer.abusive? 'х[b][/b][b][/b]ер').to eq true }

    context 'soft hypen' do # http://www.fileformat.info/info/unicode/char/00AD/index.htm
      it { expect(banhammer.abusive? 'н­ах').to eq true }
    end
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

    describe 'maximum ban duration' do
      let(:text) { 'хуй ' }
      before { allow(banhammer).to receive(:abusiveness).and_return 99999 }
      it { is_expected.to eq '4w' }
    end
  end
end
