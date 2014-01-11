require 'spec_helper'

describe Complaint do
  let(:service) { Complaint.new }
  let(:user) { create :user }

  describe :send_message do
    before do
      create :anime_video, id: 1
      create :user, id: 1077
      service.from(user).send_message "http://anime_online/videos/1", 1, :broken_video
    end

    subject { Message.all }
    it { should have(1).item }
    specify { subject.first.body.should eq "Пожаловались на видео id:1 [broken_video] http://anime_online/videos/1" }
  end
end
