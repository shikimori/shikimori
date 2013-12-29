require 'spec_helper'

describe Moderation::ComplaintAnimeVideosController do
  before { sign_in moderator }

  let(:user) { create :user }
  let(:moderator) { create :user, id: User::Blackchestnut_ID }
  let(:message) { create :message, src: user, dst: moderator, subject: :broken_video, kind: MessageType::Notification }
  let(:video) { create :anime_video, anime: create(:anime) }

  describe :index do
    before { get :index }
    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  describe :broken do
    before { get :broken, id: message.id, video_id: video.id }
    it { should redirect_to moderation_complaint_anime_videos_url }
    specify { Message.count.should be_zero }
    specify { video.reload.state.should eq 'broken' }
  end

  describe :wrong do
    before { get :wrong, id: message.id, video_id: video.id }
    it { should redirect_to moderation_complaint_anime_videos_url }
    specify { Message.count.should be_zero }
    specify { video.reload.state.should eq 'wrong' }
  end

  describe :ignore do
    before { get :ignore, id: message.id }
    it { should redirect_to moderation_complaint_anime_videos_url }
    specify { Message.count.should be_zero }
  end
end
