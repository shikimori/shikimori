describe DbEntry::Destroy do
  subject! { described_class.call entry }
  let(:entry) { create :anime }

  it do
    expect { entry.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
