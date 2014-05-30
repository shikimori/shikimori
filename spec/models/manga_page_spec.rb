require 'spec_helper'

describe MangaPage do
  it { should belong_to :chapter }

  it { should validate_presence_of :url }
  it { should validate_presence_of :number }
end
