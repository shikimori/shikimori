require 'spec_helper'

describe AnimeVideoAuthor do
  describe :factory do
    specify { build(:anime_video_author).should be_valid }
  end

  it { should have_many :anime_videos }

  it { should validate_presence_of :name }

  # хз почему не работает
  #it { should validate_uniqueness_of :name }
  describe :unique_name do
    subject { build :anime_video_author, name: name }
    let(:name) { 'test_name' }
    before { create :anime_video_author, name: name }

    its(:valid?) { should be_false }
  end
end
