describe RelatedManga do
  it { is_expected.to belong_to(:source).optional }
  it { is_expected.to belong_to(:anime).optional }
  it { is_expected.to belong_to(:manga).optional }
end
