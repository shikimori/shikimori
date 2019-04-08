describe SimilarManga do
  it { is_expected.to belong_to(:src).optional }
  it { is_expected.to belong_to(:dst).optional }
end
