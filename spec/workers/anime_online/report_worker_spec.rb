describe AnimeOnline::ReportWorker do
  let(:report) { create :anime_video_report, kind: 'broken', state: 'pending', anime_video: anime_video, user: user }
  let(:anime_video) { create :anime_video, url: url }

  subject { AnimeOnline::ReportWorker.new.perform report.id }

  describe '#perform' do
    let(:user) { create :user, id: 9999 }

    context 'vk' do
      context 'working' do
        let(:url) { 'http://vk.com/video_ext.php?oid=-14132580&id=167827617&hash=769bc0b7ba8453dc&hd=3' }
        it { should be_pending }
      end

      context 'broken' do
        let(:url) { 'https://vk.com/video_ext.php?oid=166407861&id=163627355&hash=0295006c945f8e89&hd=3' }
        it { should be_accepted }
      end

      context 'broken_not_public' do
        let(:url) { 'http://vk.com/video_ext.php?oid=-39085485&id=166452213&hash=273a3a8952a6a832&hd=2' }
        it { should be_accepted }
      end

      context 'broken_hide' do
        let(:url) { 'http://vk.com/video_ext.php?oid=-24168188&id=160084503&hash=158435bbc70b2697&hd=3' }
        it { should be_accepted }
      end
    end

    context 'sibnet' do
      context 'work' do
        let(:url) { 'http://video.sibnet.ru/shell.swf?videoid=1437504' }
        it { should be_pending }
      end

      context 'broken_error_processing_video' do
        let(:url) { 'http://video.sibnet.ru/shell.php?videoid=1047105' }
        it { should be_accepted }
      end
    end

    context 'cant_check' do
      before { create(:user, id: User::GuestID) unless User.find_by(id: User::GuestID) }
      let(:url) { 'http://vk.com/video_ext.php?oid=-14132580&id=167827617&hash=769bc0b7ba8453dc&hd=3' }

      context 'not_guest' do
        let(:user) { create :user, id: 9999 }
        it { should be_pending }
      end

      context 'guest' do
        let(:user) { User.find User::GuestID }

        context 'no_doubles' do
          it { should be_rejected }
        end

        context 'with_doubles' do
          let!(:before_report) { create :anime_video_report, kind: 'broken', state: before_state, anime_video: anime_video, user: before_user }
          let(:before_user) { create :user, id: user.id - 1 }
          let!(:report) { create :anime_video_report, kind: 'broken', state: 'pending', anime_video: anime_video, user: user }

          context 'Video has report with pending state.' do
            let(:before_state) { 'pending' }
            it { should be_pending }
          end

          context 'Video has report with rejected state - we can rejecte report from Guest.' do
            let(:before_state) { 'rejected' }
            it { should be_rejected }
          end
        end
      end
    end

    context 'uploaded' do
      let(:anime_video) { create :anime_video }
      let(:report) { create :anime_video_report, anime_video: anime_video, kind: 'uploaded', state: 'pending', user: user }
      before { AnimeOnline::Uploaders.reset }

      context 'auto_check' do
        before { allow(AnimeOnline::Uploaders).to receive(:responsible).and_return([user.id]) }
        it { expect(subject).to be_accepted }
      end

      context 'manual_check' do
        it { expect(subject).to be_pending }
      end
    end

    context 'trust_accept_broken' do
      let(:anime_video) { create :anime_video, url: "http://rutube.ru/1" }
      let(:report) { create :anime_video_report, anime_video: anime_video, kind: "broken", state: "pending", user: user }
      before { AnimeOnline::Activists.reset }

      context 'auto_check' do
        before { allow(AnimeOnline::Activists).to receive(:rutube_responsible).and_return([user.id]) }
        it { expect(subject).to be_accepted }
      end

      context 'manual_check' do
        it { expect(subject).to be_pending }
      end
    end
  end
end
