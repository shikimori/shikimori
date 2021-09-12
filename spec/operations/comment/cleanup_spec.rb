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
    let!(:comment) { create :comment, body: comment_body }
    let(:comment_body) do
      "[image=#{user_image_1.id}]\n> > [image=#{user_image_2.id}]\n\n`[image=#{user_image_3.id}]`"
    end
    let(:user_image_1) { create :user_image }
    let(:user_image_2) { create :user_image }
    let(:user_image_3) { create :user_image }

    before do
      comment.update_column :is_summary, true if is_summary
    end

    before { allow(UserImages::CleanupJob).to receive :perform_in }
    subject! { described_class.call comment, options }
    let(:options) { {} }

    context 'not summary' do
      let(:is_summary) { false }
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
    end

    context 'summary' do
      let(:is_summary) { true }

      it do
        expect(UserImages::CleanupJob).to_not have_received :perform_in
        expect(comment.body).to eq comment_body
      end

      context 'is_cleanup_summaries' do
        let(:options) { { is_cleanup_summaries: true } }
        it do
          expect(UserImages::CleanupJob).to have_received(:perform_in).once
          expect(UserImages::CleanupJob)
            .to have_received(:perform_in)
            .with(1.minute, user_image_1.id)

          expect(comment.body).to eq(
            "[image=deleted]\n> > [image=#{user_image_2.id}]\n\n`[image=#{user_image_3.id}]`"
          )
        end
      end

      context 'is_cleanup_quotes' do
        let(:is_summary) { false }
        let(:options) { { is_cleanup_quotes: true } }
        it do
          expect(UserImages::CleanupJob).to have_received(:perform_in).thrice
          expect(UserImages::CleanupJob)
            .to have_received(:perform_in)
            .with(1.minute, user_image_1.id)
          expect(UserImages::CleanupJob)
            .to have_received(:perform_in)
            .with(1.minute, user_image_2.id)
          expect(UserImages::CleanupJob)
            .to have_received(:perform_in)
            .with(1.minute, user_image_3.id)

          expect(comment.body).to eq(
            "[image=deleted]\n> > [image=deleted]\n\n`[image=deleted]`"
          )
        end
      end
    end
  end
end
