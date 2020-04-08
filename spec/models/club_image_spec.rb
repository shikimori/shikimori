describe ClubImage do
  describe 'relations' do
    it { is_expected.to belong_to :club }
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to have_attached_file :image }
    it { is_expected.to validate_attachment_presence :image }
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :club }
  end

  describe 'permissions' do
    let(:user) { build_stubbed :user, :user, :week_registered }

    subject { Ability.new user }

    let(:club) do
      build_stubbed :club,
        member_roles: [club_role].compact,
        image_upload_policy: image_upload_policy,
        bans: [club_ban].compact
    end
    let(:image) { build_stubbed :club_image, user: image_uploader, club: club }
    let(:image_uploader) { user }
    let(:image_upload_policy) { Types::Club::ImageUploadPolicy[:members] }
    let(:club_role) {}
    let(:club_ban) {}

    describe 'create' do
      context 'members image_upload_policy' do
        let(:image_upload_policy) { Types::Club::ImageUploadPolicy[:members] }

        context 'not image_owner' do
          let(:image_uploader) { build_stubbed :user }
          it { is_expected.to_not be_able_to :create, image }
        end

        context 'not member' do
          it { is_expected.to_not be_able_to :create, image }
        end

        context 'club member' do
          let(:club_role) { build_stubbed :club_role, :member, user: user }
          it { is_expected.to be_able_to :create, image }
        end
      end

      context 'admins image_upload_policy' do
        let(:image_upload_policy) { Types::Club::ImageUploadPolicy[:admins] }

        context 'not member' do
          let(:club_role) {}
          it { is_expected.to_not be_able_to :create, image }
        end

        context 'club member' do
          let(:club_role) { build_stubbed :club_role, :member, user: user }
          it { is_expected.to_not be_able_to :create, image }
        end

        context 'club admin' do
          let(:club_role) { build_stubbed :club_role, :admin, user: user }
          it { is_expected.to be_able_to :create, image }
        end
      end
    end

    describe 'destroy' do
      describe 'image owner' do
        context 'not member' do
          it { is_expected.to_not be_able_to :destroy, image }
        end

        context 'club member' do
          let(:club_role) { build_stubbed :club_role, :member, user: user }
          it { is_expected.to be_able_to :destroy, image }
        end
      end

      describe 'not image owner' do
        let(:image_uploader) { build_stubbed :user }

        context 'not member' do
          it { is_expected.to_not be_able_to :destroy, image }
        end

        context 'club member' do
          let(:club_role) { build_stubbed :club_role, :member, user: user }
          it { is_expected.to_not be_able_to :destroy, image }
        end

        context 'club admin' do
          let(:club_role) { build_stubbed :club_role, :admin, user: user }
          it { is_expected.to be_able_to :destroy, image }
        end
      end
    end
  end
end
