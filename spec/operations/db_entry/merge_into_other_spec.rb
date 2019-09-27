describe DbEntry::MergeIntoOther do
  let(:manga_1) { create :manga }
  let(:manga_2) { create :manga }

  let!(:user_rate_1_1) { create :user_rate, target: manga_1, user: user_1 }
  let!(:user_rate_1_2) { create :user_rate, target: manga_2, user: user_1 }
  let!(:user_rate_2_1) { create :user_rate, target: manga_1, user: user_2 }

  let!(:user_rate_log_1) { create :user_rate_log, target: manga_1, user: user_1 }
  let!(:user_rate_log_2) { create :user_rate_log, target: manga_1, user: user_2 }

  let!(:user_history_1) { create :user_history, target: manga_1, user: user_1 }
  let!(:user_history_2) { create :user_history, target: manga_1, user: user_2 }

  let!(:topic_1) { create :topic, linked: manga_1 }
  let!(:topic_2) { create :topic, linked: manga_1, generated: true }

  let!(:review) { create :review, target: manga_1 }

  let(:collection) { create :collection }
  let!(:collection_link) { create :collection_link, linked: manga_1, collection: collection }

  let!(:version) { create :version, item: manga_1 }

  let(:club) { create :club }
  let!(:club_link) { create :club_link, linked: manga_1, club: club }

  let(:cosplay_gallery) { create :cosplay_gallery }
  let!(:cosplay_gallery_link) do
    create :cosplay_gallery_link, linked: manga_1, cosplay_gallery: cosplay_gallery
  end

  let!(:recommendation_ignore) { create :recommendation_ignore, target: manga_1 }

  subject! { described_class.call entry: manga_1, other: manga_2 }

  it do
    expect { manga_1.reload }.to raise_error ActiveRecord::RecordNotFound

    expect { user_rate_1_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_rate_log_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_history_1.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(user_rate_2_1.reload.target).to eq manga_2
    expect(user_rate_log_2.reload.target).to eq manga_2
    expect(user_history_2.reload.target).to eq manga_2

    expect(topic_1.reload.linked).to eq manga_2
    expect { topic_2.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(review.reload.target).to eq manga_2
    expect(collection_link.reload.linked).to eq manga_2
    expect(version.reload.item).to eq manga_2
    expect(club_link.reload.linked).to eq manga_2
    expect(cosplay_gallery_link.reload.linked).to eq manga_2
    expect(recommendation_ignore.reload.target).to eq manga_2
  end
end
