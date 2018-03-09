describe AnimeOnline::CleanupAnimeVideos do
  let(:worker) { AnimeOnline::CleanupAnimeVideos.new }

  let(:old) { AnimeOnline::CleanupAnimeVideos::CLEANUP_INTERVAL.ago - 1.hour }
  let(:new) { AnimeOnline::CleanupAnimeVideos::CLEANUP_INTERVAL.ago + 1.hour }

  let!(:working_video) { create :anime_video, :working, updated_at: old }
  let!(:uploaded_video) { create :anime_video, :uploaded, updated_at: old }
  let!(:rejected_video) { create :anime_video, :rejected, updated_at: old }
  let!(:broken_video) { create :anime_video, :broken, updated_at: old }
  let!(:wrong_video) { create :anime_video, :wrong, updated_at: old }
  let!(:banned_video) { create :anime_video, :banned_hosting, updated_at: old }
  let!(:copyrighted_video) { create :anime_video, :copyrighted, updated_at: old }

  let!(:broken_video_new) { create :anime_video, :broken, updated_at: new }

  subject! { worker.perform }

  it do
    expect(working_video.reload).to be_persisted
    expect(uploaded_video.reload).to be_persisted

    expect { rejected_video.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { broken_video.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { wrong_video.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { banned_video.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { copyrighted_video.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(broken_video_new.reload).to be_persisted
  end
end
