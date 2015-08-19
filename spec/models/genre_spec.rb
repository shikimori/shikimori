describe Genre do
  describe 'relations' do
    it { have_and_belong_to_many :animes }
    it { have_and_belong_to_many :mangas }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in :anime, :manga }
  end
end
