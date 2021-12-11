describe Review::Destroy do
  subject { described_class.call review, faye }

  let(:faye) { FayeService.new user, nil }
  let!(:review) { create :review, anime: anime }
  let(:anime) { create :anime }

  it do
    expect { subject }.to change(Review, :count).by(-1)
    expect { review.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
