describe Publisher do
  # по-моему какой-то баг в rails 4
  # TODO: проверить, не заработало ли в rails 4.1
  # it { is_expected.to have_and_belong_to_many :mangas }

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
  end
end
