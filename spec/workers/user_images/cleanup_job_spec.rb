describe UserImages::CleanupJob do
  subject! { described_class.new.perform user_image_id }
  let(:user_image_id) { user_image.id }
  let(:user_image) { create :user_image }

  it do
    expect { user_image.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
