describe AnimeVideoReport do
  describe 'relations' do
    it { is_expected.to belong_to :anime_video }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:approver).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :kind }

    describe 'accepted' do
      subject { build :anime_video_report, state: 'accepted' }
      it { is_expected.to validate_presence_of :approver }
    end

    describe 'rejected' do
      subject { build :anime_video_report, state: 'rejected' }
      it { is_expected.to validate_presence_of :approver }
    end
  end
end
