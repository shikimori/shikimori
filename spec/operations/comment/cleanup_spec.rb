describe Comment::Cleanup do
  describe '.scan_user_image_ids' do
    subject do
      described_class.scan_user_image_ids(
        "[image=555]\n> > [poster=123456]\n\n`[image=234567]`\n[image=234567]"
      )
    end
    it { is_expected.to eq [555, 123456, 234567] }
  end

  describe '#call' do
    let!(:comment) { create :comment, body: comment_body, user: user }
    let(:comment_body) do
      "[image=#{user_image_1.id}]\n> > [image=#{user_image_2.id}]\n\n`[image=#{user_image_3.id}]`"
    end
    let(:user_image_1) { create :user_image, user: user }
    let(:user_image_2) { create :user_image, user: user }
    let(:user_image_3) { create :user_image, user: user }

    before { allow(UserImages::CleanupJob).to receive :perform_in }
    subject! { described_class.call comment, options }
    let(:options) { {} }

    it do
      expect(UserImages::CleanupJob).to have_received(:perform_in).once
      expect(UserImages::CleanupJob)
        .to have_received(:perform_in)
        .with(1.minute, user_image_1.id)

      expect(comment.body).to eq(
        "[image=deleted]\n> > [image=#{user_image_2.id}]\n\n`[image=#{user_image_3.id}]`"
      )
    end

    context 'skip_model_update' do
      let(:options) { { skip_model_update: true } }
      it do
        expect(UserImages::CleanupJob).to have_received(:perform_in).once
        expect(UserImages::CleanupJob)
          .to have_received(:perform_in)
          .with(1.minute, user_image_1.id)
        expect(comment.body).to eq comment_body
      end
    end

    context 'do not destroy images of other users' do
      let(:user_image_1) { create :user_image, user: user_2 }
      it do
        expect(UserImages::CleanupJob).to_not have_received :perform_in
        expect(comment.body).to eq comment_body
      end
    end
  end
end
