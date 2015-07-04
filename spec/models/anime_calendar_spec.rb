describe AnimeCalendar do
  describe 'relations' do
    it { should belong_to :anime }
  end

  describe 'validations' do
    it { should validate_presence_of :anime }
    it { should validate_presence_of :episode }
    it { should validate_presence_of :start_at }
  end
end
