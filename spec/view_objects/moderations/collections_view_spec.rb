describe Moderations::CollectionsView do
  include_context :view_context_stub

  let(:view) { described_class.new }

  let!(:collection_1) do
    create :collection, :accepted, :published, approver: user
  end
  let!(:collection_2) do
    create :collection, :pending, :published, approver: user
  end
  let!(:collection_3) do
    create :collection, %i[accepted pending].sample, approver: user_3
  end
  let!(:collection_4) do
    create :collection, :rejected, :published, approver: user_2
  end

  it do
    expect(view.processed).to eq [collection_4, collection_1]
    expect(view.pending).to eq [collection_2]
  end
end
