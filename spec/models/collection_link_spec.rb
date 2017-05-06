describe CollectionLink do
  describe 'relations' do
    it { is_expected.to belong_to :collection }
    it { is_expected.to belong_to :linked }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :collection }
    # it { is_expected.to validate_uniqueness_of(:linked_id).scoped_to(:collection_id) }
  end

  describe 'enumerize' do
    it do
      is_expected
        .to enumerize(:linked_type)
        .in(:Anime, :Manga, :Character, :Person)
    end
  end
end
