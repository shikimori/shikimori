describe ClubLink do
  describe 'relations' do
    it { is_expected.to belong_to :club }
    it { is_expected.to belong_to :linked }
  end
end
