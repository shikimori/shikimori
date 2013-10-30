require 'spec_helper'

describe AnimeVideo do
  it { should belong_to(:anime) }
  it { should belong_to(:author) }
end
