require 'spec_helper'

describe AnimeVideoAuthor do
  describe :factory do
    specify { build(:anime_video_author).should be_valid }
  end

  it { should have_many :anime_videos }

  it { should validate_presence_of :name }
end
