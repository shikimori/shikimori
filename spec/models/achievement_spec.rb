describe Achievement do
  describe 'relations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :neko_id }
    it { is_expected.to validate_presence_of :level }
    it { is_expected.to validate_presence_of :progress }
  end

  describe 'enumerize' do
    it do
      is_expected
        .to enumerize(:neko_id)
        .in(*Types::Achievement::NekoId.values)
    end
  end
end
