require 'spec_helper'

describe AnimeVideo do
  it { should belong_to :anime }
  it { should belong_to :author }

  it { should validate_presence_of :anime }
  it { should validate_presence_of :url }
  it { should validate_presence_of :source }

  describe :hosting do
    subject { build(:anime_video, url: url).hosting }

    context :valid_url do
      let(:url) { 'http://vk.com/video_ext.php?oid=1' }
      it { should eq 'vk.com' }
    end

    context :remove_www do
      let(:url) { 'http://www.vk.com?id=1' }
      it { should eq 'vk.com' }
    end
  end
end
