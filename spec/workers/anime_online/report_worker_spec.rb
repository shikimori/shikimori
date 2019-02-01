describe AnimeOnline::ReportWorker, vcr: { cassette_name: 'anime_video_report_worker' } do
  let(:report) do
    create :anime_video_report,
      kind: 'broken',
      state: 'pending',
      anime_video: anime_video,
      user: user,
      message: message
  end
  let(:anime_video) { create :anime_video, url: url, anime: anime }
  let(:anime) { create :anime }
  let(:message) { nil }

  subject { AnimeOnline::ReportWorker.new.perform report.id }
  let(:user) { create :user, id: 9999 }

  context 'broken' do
    context 'vk' do
      context 'working' do
        let(:url) { 'http://vk.com/video_ext.php?oid=-14132580&id=167827617&hash=769bc0b7ba8453dc&hd=3' }
        it { is_expected.to be_pending }
      end

      context 'broken' do
        let(:url) { 'https://vk.com/video_ext.php?oid=166407861&id=163627355&hash=0295006c945f8e89&hd=3' }

        context 'without message' do
          it { is_expected.to be_accepted }
        end

        context 'with message' do
          let(:message) { 'test' }
          it { is_expected.to be_pending }
        end
      end

      context 'broken_not_public' do
        let(:url) { 'http://vk.com/video_ext.php?oid=-39085485&id=166452213&hash=273a3a8952a6a832&hd=2' }
        it { is_expected.to be_accepted }
      end

      context 'broken_hide' do
        let(:url) { 'http://vk.com/video_ext.php?oid=-24168188&id=160084503&hash=158435bbc70b2697&hd=3' }
        it { is_expected.to be_accepted }
      end

      context 'adult export forbidden' do
        let(:url) { 'http://vk.com/video_ext.php?oid=-23314707&id=160661445&hash=5bc587ab61aace17&hd=3' }
        it { is_expected.to be_accepted }
      end
    end

    context 'sibnet' do
      context 'work' do
        let(:url) { 'http://video.sibnet.ru/shell.swf?videoid=1437504' }
        it { is_expected.to be_pending }
      end

      context 'broken_error_processing_video' do
        let(:url) { 'http://video.sibnet.ru/shell.php?videoid=1047105' }
        it { is_expected.to be_accepted }
      end
    end

    context 'cant_check' do
      before { create(:user, id: User::GUEST_ID) unless User.find_by(id: User::GUEST_ID) }
      let(:url) { 'http://vk.com/video_ext.php?oid=-14132580&id=167827617&hash=769bc0b7ba8453dc&hd=3' }

      context 'not_guest' do
        let(:user) { create :user, id: 9999 }
        it { is_expected.to be_pending }
      end

      context 'guest' do
        let(:user) { User.find User::GUEST_ID }

        context 'no_doubles' do
          it { is_expected.to be_rejected }
        end

        context 'with_doubles' do
          let!(:before_report) do
            create :anime_video_report,
              kind: 'broken',
              state: before_state,
              anime_video: anime_video,
              user: before_user
          end
          let(:before_user) { create :user, id: user.id - 1 }
          let!(:report) do
            create :anime_video_report,
              kind: 'broken',
              state: 'pending',
              anime_video: anime_video,
              user: user
          end

          context 'Video has report with pending state.' do
            let(:before_state) { 'pending' }
            it { is_expected.to be_pending }
          end

          context 'Video has report with rejected state - we can rejecte report from Guest.' do
            let(:before_state) { 'rejected' }
            it { is_expected.to be_rejected }
          end
        end
      end
    end

    context 'trust accept broken' do
      let(:anime_video) do
        create :anime_video,
          url: 'http://video.sibnet.ru/shell.php?videoid=3540992',
          anime: anime
      end
      let(:report) do
        create :anime_video_report,
          anime_video: anime_video,
          kind: 'broken',
          state: 'pending',
          user: user
      end
      # before { AnimeOnline::Activists.reset }

      # context 'auto_check' do
      #   before do
      #     allow(AnimeOnline::Activists)
      #       .to receive(:rutube_responsible)
      #       .and_return([user.id])
      #   end
      #   it { is_expected.to be_accepted }
      # end

      context 'manual_check' do
        it { is_expected.to be_pending }
      end
    end
  end

  context 'uploaded' do
    let(:anime_video) { create :anime_video, :uploaded, anime: anime }
    let(:report) do
      create :anime_video_report,
        anime_video: anime_video,
        kind: 'uploaded',
        state: 'pending',
        user: user
    end

    context 'auto check' do
      before do
        allow(AnimeOnline::UploaderPolicy)
          .to receive(:new)
          .and_return uploader_policy
      end
      let(:uploader_policy) { double 'trusted?': is_trusted }

      context 'trusted' do
        let(:is_trusted) { true }
        it { is_expected.to be_accepted }

        context 'announced anime' do
          let(:anime) { create :anime, :anons }

          context 'cannot manage report' do
            it { is_expected.to be_pending }
          end

          context 'can manage report' do
            let(:user) { create :user, :video_moderator }
            it { is_expected.to be_accepted }
          end
        end
      end

      context 'not trusted' do
        let(:is_trusted) { false }

        context 'cannot manage report' do
          it { is_expected.to be_pending }
        end

        context 'can manage report' do
          let(:user) { create :user, :video_moderator }
          it { is_expected.to be_accepted }
        end
      end
    end

    context 'manual_check' do
      it { is_expected.to be_pending }
    end
  end
end
