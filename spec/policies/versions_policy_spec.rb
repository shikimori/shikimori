describe VersionsPolicy do
  context '.version_allowed?' do
    subject { described_class.version_allowed? user, version }

    let(:version) { build :version, item: item, item_diff: item_diff, user: author }
    let(:author) { user }
    let(:user) { seed :user }

    let(:item) { build_stubbed :anime }
    let(:item_diff) do
      {
        field => [change_from, change_to]
      }
    end
    let(:field) { :russian }
    let(:change_from) { 'a' }
    let(:change_to) { 'b' }

    it { is_expected.to eq true }

    context 'user banned' do
      before { user.read_only_at = 1.hour.from_now }
      it { is_expected.to eq false }
    end

    context 'not_trusted_version_changer' do
      before { user.roles = %i[not_trusted_version_changer] }
      it { is_expected.to eq false }
    end

    context 'not_trusted_names_changer' do
      before { user.roles = %i[not_trusted_names_changer] }

      context 'not name field' do
        let(:field) { 'description_ru' }
        it { is_expected.to eq true }
      end

      context 'name field' do
        context 'not DbEntry model' do
          let(:item) { build_stubbed :video }
          it { is_expected.to eq true }
        end

        context 'DbEntry model' do
          it { is_expected.to eq false }
        end
      end
    end

    context 'not matched author' do
      let(:author) { user_2 }
      it { is_expected.to eq false }
    end

    context 'changed restricted field' do
      let(:field) { :name }

      context 'from nil to value' do
        let(:change_from) { nil }
        it { is_expected.to eq true }
      end

      context 'from value to value' do
        it { is_expected.to eq false }
      end
    end
  end
end
