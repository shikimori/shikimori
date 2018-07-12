describe PgCacheData do
  describe 'validations' do
    it { is_expected.to validate_presence_of :key }
    it { is_expected.to validate_presence_of :value }
  end
end
