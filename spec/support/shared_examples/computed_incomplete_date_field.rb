shared_examples :computed_incomplete_date_field do |db_entry, field|
  context 'computed incomplete_date field' do
    let(:model) { build_stubbed db_entry }
    before { model.send :"#{field}=", IncompleteDate.new(value) }

    context 'has value' do
      let(:value) { '1992-08-25' }
      it do
        expect(model.send(:"#{field}_computed")).to eq Date.parse value
      end
    end

    context 'no value' do
      let(:value) { ['', nil].sample }
      it do
        expect(model.send(:"#{field}_computed")).to be_nil
      end
    end
  end
end
