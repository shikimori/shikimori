require 'spec_helper'

describe AnimeVideoReportWorker do
  before { SiteParserWithCache.stub(:load_cache).and_return entries: {} }
  before { SiteParserWithCache.stub :save_cache }
  before { create :user, id: User::GuestID }
  let(:report) { create :anime_video_report, kind: 'broken', state: 'pending', anime_video: anime_video, user: user }
  let(:anime_video) { create :anime_video, url: url }

  subject { AnimeVideoReportWorker.new.perform report.id }

  describe :perform do
    let(:user) { create :user }

    context :vk do
      context :working do
        let(:url) { 'http://vk.com/video_ext.php?oid=-14132580&id=167827617&hash=769bc0b7ba8453dc&hd=3' }
        it { should be_pending }
      end

      context :broken do
        let(:url) { 'https://vk.com/video_ext.php?oid=166407861&id=163627355&hash=0295006c945f8e89&hd=3' }
        it { should be_accepted }
      end

      context :broken_not_public do
        let(:url) { 'http://vk.com/video_ext.php?oid=-39085485&id=166452213&hash=273a3a8952a6a832&hd=2' }
        it { should be_accepted }
      end

      context :broken_hide do
        let(:url) { 'http://vk.com/video_ext.php?oid=-24168188&id=160084503&hash=158435bbc70b2697&hd=3' }
        it { should be_accepted }
      end
    end

    context :cant_check do
      before { AnimeVideoReportWorker.any_instance.stub(:is_broken).and_return false }
      let(:url) { 'http://vk.com/video_ext.php?oid=-14132580&id=167827617&hash=769bc0b7ba8453dc&hd=3' }

      context :not_guest do
        let(:user) { create :user }
        it { should be_pending }
      end

      context :guest do
        let(:user) { User.find User::GuestID }

        context :no_doubles do
          it { should be_rejected }
        end

        context :with_doubles do
          let(:other_user) { create :user }
          let!(:other_report) { create :anime_video_report, kind: 'broken', state: 'pending', anime_video: anime_video, user: other_user }
          it { should be_pending }
        end
      end
    end
  end
end
