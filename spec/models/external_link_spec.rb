describe ExternalLink do
  describe 'associations' do
    it { is_expected.to belong_to :entry }
  end

  describe 'validations' do
    it do
      is_expected.to validate_presence_of :entry
      is_expected.to validate_presence_of :source
      is_expected.to validate_presence_of :url
    end
  end

  describe 'enumerize' do
    it do
      is_expected.to enumerize(:source).in(*Types::ExternalLink::Source.values)
    end
  end
end
