require 'spec_helper'

describe AnimeVideo do
  describe :factory do
    specify { build(:anime_video).should be_valid }
  end

  it { should belong_to :anime }
  it { should belong_to :author }

  it { should validate_presence_of :anime }
  it { should validate_presence_of :url }
  it { should validate_presence_of :source }
end
