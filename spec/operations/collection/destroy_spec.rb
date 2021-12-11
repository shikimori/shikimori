describe Collection::Destroy do
  subject { described_class.call collection, user }
  let!(:collection) { create :collection }

  it do
    expect { subject }.to change(Collection, :count).by(-1)
    expect { collection.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
