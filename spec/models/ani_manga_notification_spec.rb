require 'spec_helper'

describe AniMangaNotification do
  it { should validate_presence_of :item_id }
  it { should validate_presence_of :item_type }

  describe '.video_episode' do
    let(:anime_video) { build_stubbed :anime_video }
    subject { AniMangaNotification.video_episode anime_video }

    it { expect{subject}.to change(AniMangaNotification, :count).by 1 }
    its(:item_id) { should eq anime_video.id }
    its(:item_type) { should eq AnimeVideo.name }
  end
end
