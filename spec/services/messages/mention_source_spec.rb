describe Messages::MentionSource do
  subject { described_class.call linked, comment_id: comment_id }
  let(:comment_id) { nil }

  context 'nil' do
    let(:linked) { nil }
    it { is_expected.to eq 'в <em>удалено</em>.' }
    it { is_expected.to be_html_safe }
  end

  context 'Topic' do
    let(:user) { build_stubbed :user, :user }
    let(:linked) { build_stubbed :topic, id: 1, title: 'xx&', user: user }
    it { is_expected.to eq "в топике <a href=\"#{Shikimori::PROTOCOL}://test.host/forum/offtopic/1-xx\">xx&amp;</a>." }
  end

  context 'User' do
    let(:linked) { build_stubbed :user, id: 1, nickname: 'zz' }
    it { is_expected.to eq "в профиле пользователя <a href=\"#{Shikimori::PROTOCOL}://test.host/zz\">zz</a>." }
  end

  context 'other linked' do
    let(:linked) { build_stubbed :anime, id: 1, name: 'cc' }
    it { expect { subject }.to raise_error ArgumentError, 'Anime 1-cc' }
  end
end
