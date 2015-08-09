describe VersionDecorator do
  let(:decorator) { version.decorate }
  let(:version) { build_stubbed :version, item_diff: { name: [1,2], russian: [3,4] }, user: user }
  let(:user) { build_stubbed :user }

  describe '#user' do
    context 'site user' do
      it { expect(decorator.user).to eq version.user }
    end

    context 'guest' do
      let(:user) { nil }
      let!(:guest) { create :user, id: User::GuestID }
      it { expect(decorator.user).to eq guest }
    end
  end

  describe '#changed_fields' do
    it { expect(decorator.changed_fields).to eq ['name', 'russian'] }
  end

  describe '#changes_template' do
    it { expect(decorator.changes_tempalte :name).to eq 'versions/text_diff' }
  end
end
