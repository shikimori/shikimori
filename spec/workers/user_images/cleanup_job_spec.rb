describe UserImages::CleanupJob do
  let(:user_image) { create :user_image }
  let!(:some_model) { nil }

  subject! { described_class.new.perform user_image.id }

  context 'not used anywhere' do
    it do
      expect { user_image.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context 'used somewhere' do
    let!(:some_model) { create :poll, text: "[image=#{user_image.id}]" }

    it do
      expect(user_image.reload).to be_persisted
    end
  end

  context 'used in some comment' do
    let!(:some_model) do
      create :comment,
        body: [
          "[image=#{user_image.id}]",
          "[poster=#{user_image.id}]",
          "[image=#{user_image.id} ",
          "[poster=#{user_image.id} "
        ].sample
    end

    it do
      expect(user_image.reload).to be_persisted
    end
  end
end
