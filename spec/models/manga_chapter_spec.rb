require 'spec_helper'

describe MangaChapter do
  it { should belong_to :manga }

  it { should validate_presence_of :name }
  it { should validate_presence_of :url }
end
