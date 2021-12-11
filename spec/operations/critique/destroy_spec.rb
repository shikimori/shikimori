describe Critique::Destroy do
  subject { described_class.call critique, user }
  let!(:critique) { create :critique }

  it do
    expect { subject }.to change(Critique, :count).by(-1)
    expect { critique.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
