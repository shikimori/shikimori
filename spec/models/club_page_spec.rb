describe ClubPage do
  describe 'relations' do
    it { is_expected.to belong_to(:club).touch }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:parent_page).optional }
    it { is_expected.to have_many(:child_pages).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:text).is_at_most(150000) }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:layout).in(*Types::ClubPage::Layout.values) }
  end

  describe 'instance methods' do
    describe '#to_param' do
      let(:club_page) { build :club_page, id: 1, name: 'тест' }
      it { expect(club_page.to_param).to eq '1-test' }
    end

    describe '#parents' do
      let(:club_page_1) { build :club_page, parent_page: club_page_2 }
      let(:club_page_2) { build :club_page, parent_page: club_page_3 }
      let(:club_page_3) { build :club_page }

      it { expect(club_page_1.parents).to eq [club_page_3, club_page_2] }
      it { expect(club_page_2.parents).to eq [club_page_3] }
      it { expect(club_page_3.parents).to eq [] }
    end

    describe '#siblings' do
      let(:club_page) { build :club_page, parent_page: parent_page, club: club }
      let(:club) { build :club }
      let(:siblings) { [build(:club_page)] }

      context 'with parent_page' do
        let(:parent_page) { build :club_page }
        before { allow(parent_page).to receive(:child_pages).and_return siblings }
        it { expect(club_page.siblings).to eq siblings }
      end

      context 'without parent_page' do
        let(:parent_page) { nil }
        before { allow(club).to receive(:root_pages).and_return siblings }
        it { expect(club_page.siblings).to eq siblings }
      end
    end
  end

  describe 'permissions' do
    let(:user) { build_stubbed :user, :user, :day_registered }
    let(:club_page) { build_stubbed :club_page, club: club, parent_page: parent_page }
    let(:parent_page) { nil }

    subject { Ability.new user }

    context 'can edit club' do
      let(:club) { build_stubbed :club, owner: user }

      context 'without parent_page' do
        it { is_expected.to be_able_to :new, club_page }
        it { is_expected.to be_able_to :create, club_page }
        it { is_expected.to be_able_to :update, club_page }
        it { is_expected.to be_able_to :destroy, club_page }
        it { is_expected.to be_able_to :up, club_page }
        it { is_expected.to be_able_to :down, club_page }
        it { is_expected.to be_able_to :read, club_page }
      end

      context 'with parent_page' do
        context 'same club page' do
          let(:parent_page) { build_stubbed :club_page, club: club }

          it { is_expected.to be_able_to :new, club_page }
          it { is_expected.to be_able_to :create, club_page }
          it { is_expected.to be_able_to :update, club_page }
          it { is_expected.to be_able_to :destroy, club_page }
          it { is_expected.to be_able_to :up, club_page }
          it { is_expected.to be_able_to :down, club_page }
          it { is_expected.to be_able_to :read, club_page }
        end

        context 'another club page' do
          let(:parent_page) { build_stubbed :club_page, club: build_stubbed(:club) }

          it { is_expected.to_not be_able_to :new, club_page }
          it { is_expected.to_not be_able_to :create, club_page }
          it { is_expected.to_not be_able_to :update, club_page }
          it { is_expected.to_not be_able_to :destroy, club_page }
          it { is_expected.to_not be_able_to :up, club_page }
          it { is_expected.to_not be_able_to :down, club_page }
          it { is_expected.to be_able_to :read, club_page }
        end
      end
    end

    context "can't edit club" do
      let(:club) { build_stubbed :club }

      it { is_expected.to_not be_able_to :new, club_page }
      it { is_expected.to_not be_able_to :create, club_page }
      it { is_expected.to_not be_able_to :update, club_page }
      it { is_expected.to_not be_able_to :destroy, club_page }
      it { is_expected.to_not be_able_to :up, club_page }
      it { is_expected.to_not be_able_to :down, club_page }
      it { is_expected.to be_able_to :read, club_page }
    end
  end

  it_behaves_like :topics_concern, :club_page
  it_behaves_like :antispam_concern, :club_page
end
