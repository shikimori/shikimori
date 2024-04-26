describe TopicIgnore, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :topic }
  end
end
