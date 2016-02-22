describe Messages::GenerateBody do
  let(:service) { Messages::GenerateBody.new message }
  subject { service.call }

  describe '#call' do
    context 'private' do
      let(:message) { build :message, kind: 'Private', body: '[b]test[/b]' }
      it { is_expected.to eq '<strong>test</strong>' }
      it { is_expected.to be_html_safe }
    end

    context 'notification' do
    end

    context 'nickname_changed' do
    end

    context 'ongoing' do
    end

    context 'anons' do
    end

    context 'episode' do
    end

    context 'released' do
    end

    context 'site_news' do
    end

    context 'profile_commented' do
    end

    context 'friend_request' do
    end

    context 'quoted_by_user' do
    end

    context 'subscription_commented' do
    end

    context 'warned' do
    end

    context 'banned' do
    end

    context 'club_request' do
    end

    context 'version_accepted' do
    end

    context 'version_rejected' do
    end

    context 'contest_finished' do
    end
  end
end
