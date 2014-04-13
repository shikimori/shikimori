require 'spec_helper'

describe AnimeOnline::AnimeVideosService do
  let(:user) { create :user }
  let(:video) { create :anime_video, state: 'uploaded' }

  describe :upload_report do
    subject { AnimeOnline::AnimeVideosService.upload_report user, video }

    its(:kind) { should be_uploaded }

    context :not_trusted_user do
      it { should be_pending }
    end

    context :trusted_user do
      before { stub_const 'User::TrustedVideoUploaders', [ user.id ] }
      let(:video) { create :anime_video, state: 'uploaded' }
      it { should be_accepted }
      its(:approver) { should eq user }
    end
  end
end
