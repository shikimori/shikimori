describe Users::CleanupStyles do
  let(:user_1) do
    create :user,
      nickname: 'not old',
      last_online_at: described_class::CLEANUP_INTERVAL.ago + 1.day
  end
  let(:user_2) do
    create :user,
      nickname: 'old',
      last_online_at: described_class::CLEANUP_INTERVAL.ago - 1.day
  end

  let!(:style_1) { create :style, owner: user_1, compiled_css: 'zz' }
  let!(:style_2) { create :style, owner: user_2, compiled_css: 'zz' }

  subject! { described_class.new.perform }

  it do
    expect(style_1.reload.compiled_css).to eq 'zz'
    expect(style_2.reload.compiled_css).to be_nil
  end
end
