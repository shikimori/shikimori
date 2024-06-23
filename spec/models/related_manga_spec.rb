describe RelatedManga do
  describe 'relations' do
    it { is_expected.to belong_to(:source).optional }
    it { is_expected.to belong_to(:anime).optional }
    it { is_expected.to belong_to(:manga).optional }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:relation_kind).in(*Types::RelatedAniManga::RelationKind.values) }
  end
end
