describe CollectionRole do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:club).touch(true) }
  end
end
