
describe SimilarAnime, :type => :model do
  it { should belong_to :src }
  it { should belong_to :dst }
end
