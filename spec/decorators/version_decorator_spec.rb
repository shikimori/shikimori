describe VersionDecorator do
  let(:decorator) { version.decorate }
  let(:version) { build_stubbed :version, user: user, item: item, state: state,
    item_diff: { name: ['1','2'], russian: ['3','4'] } }
  let(:user) { build_stubbed :user }
  let(:item) { build_stubbed :anime }
  let(:state) { 'pending' }

  describe '#user' do
    context 'site user' do
      it { expect(decorator.user).to eq version.user }
    end

    context 'guest' do
      let(:user) { nil }
      let!(:guest) { create :user, id: User::GUEST_ID }
      it { expect(decorator.user).to eq guest }
    end
  end

  describe '#changed_fields' do
    it { expect(decorator.changed_fields).to eq ['Английское название', 'Русское название'] }
  end

  describe '#changes_template' do
    it { expect(decorator.changes_tempalte :name).to eq 'versions/text_diff' }
  end

  describe '#item_template' do
    describe 'anime video' do
      let(:item) { build_stubbed :anime_video }
      it { expect(decorator.item_template).to eq 'versions/anime_video' }
    end

    describe 'db_entry' do
      it { expect(decorator.item_template).to eq 'versions/db_entry' }
    end
  end

  describe '#old_value' do
    context 'pending' do
      let(:state) { 'pending' }
      it { expect(decorator.old_value :name).to eq item.name }
    end

    context 'rejected' do
      let(:state) { 'rejected' }
      it { expect(decorator.old_value :name).to eq item.name }
    end

    context 'other' do
      let(:state) { 'accepted' }
      it { expect(decorator.old_value :name).to eq version.item_diff['name'].first }
    end
  end

  describe '#field_value' do
    describe 'anime_video_author_id' do
      context 'present author' do
        let(:author) { create :anime_video_author }
        it { expect(decorator.field_value :anime_video_author_id, author.id).to eq author.name }
      end

      context 'no author' do
        it { expect(decorator.field_value :anime_video_author_id, '').to be_nil }
      end
    end

    describe 'other fields' do
      it { expect(decorator.field_value :name, 'test').to eq 'test' }
    end
  end
end
