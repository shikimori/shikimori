describe SummaryViewing do
  context 'associations' do
    it { is_expected.to belong_to :user }
    it do
      is_expected.to belong_to(:viewed)
        .class_name(Summary.name)
        .inverse_of(:viewings)
    end
  end
end
