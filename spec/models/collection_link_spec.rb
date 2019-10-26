describe CollectionLink do
  describe 'relations' do
    it { is_expected.to belong_to :collection }
    it { is_expected.to belong_to :linked }
    Types::Collection::Kind.values.each do |kind|
      it { is_expected.to belong_to(kind).optional }
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :collection }
    # it { is_expected.to validate_uniqueness_of(:linked_id).scoped_to(:collection_id) }

    context 'censored' do
      before { subject.linked = build_stubbed(:anime, is_censored: true) }
      it do
        is_expected.to_not be_valid
        expect(subject.errors[:linked]).to eq [
          I18n.t('activerecord.errors.models.collection_link.attributes.linked.censored')
        ]
      end
    end
  end

  describe 'enumerize' do
    it do
      is_expected
        .to enumerize(:linked_type)
        .in(*Types::Collection::Kind.values.map(&:to_s).map(&:classify))
    end
  end
end
