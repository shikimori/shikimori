describe Svd do
  describe 'validations' do
    it { should validate_presence_of :lsa }
    it { should validate_presence_of :entry_ids }
    it { should validate_presence_of :user_ids }
  end

  describe 'enumerize' do
    it { should enumerize(:scale).in(:full, :partial) }
    it { should enumerize(:kind).in(:anime) }
    it { should enumerize(:normalization).in(:none, :mean_centering, :z_score) }
  end

  describe 'instance methods' do
    let(:svd) { build :svd, normalization: :z_score, kind: :anime }

    describe '#normalizer' do
      it { expect(svd.normalizer).to be_kind_of Recommendations::Normalizations::ZScore }
    end

    describe '#klass' do
      it { expect(svd.klass).to eq Anime }
    end
  end
end
