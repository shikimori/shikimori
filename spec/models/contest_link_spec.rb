describe ContestLink do
  describe 'relations' do
    it { is_expected.to belong_to :contest }
    it { is_expected.to belong_to :linked }
  end
end
