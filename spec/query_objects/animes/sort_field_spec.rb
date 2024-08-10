describe Animes::SortField do
  let(:query) { Animes::SortField.new default, view_context }

  let(:default) { :zz }
  let(:view_context) do
    double(
      russian_names?: russian_names,
      params: { order: }
    )
  end
  let(:russian_names) { true }

  describe '#field' do
    context 'order not set' do
      let(:order) { nil }

      context 'default name or russian' do
        let(:default) { 'name' }
        it { expect(query.field).to eq 'russian' }
      end

      context 'other default' do
        it { expect(query.field).to eq default }
      end
    end

    context 'some field' do
      let(:order) { 'zzz' }
      it { expect(query.field).to eq order }
    end

    context 'name or russian order' do
      let(:order) { 'name' }

      context 'russian_names' do
        let(:russian_names) { true }
        it { expect(query.field).to eq 'russian' }
      end

      context 'not russian_names' do
        let(:russian_names) { false }
        it { expect(query.field).to eq 'name' }
      end
    end
  end
end
