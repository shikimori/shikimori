
require 'spec_helper'

describe SimilarAnime do
  it { should belong_to :src }
  it { should belong_to :dst }
end
