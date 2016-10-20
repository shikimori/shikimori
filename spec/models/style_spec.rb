describe Style do
  describe 'relations' do
    it { is_expected.to belong_to :owner }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :owner }
  end

  describe 'instance method' do
    describe '#safe_css' do
      let(:style) { build :style, css: 'body { color: red; }; javascript:blablalba;;' }
      it { expect(style.safe_css).to eq 'body { color: red; }; :blablalba;' }
    end
  end
end
