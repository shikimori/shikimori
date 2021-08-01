describe DbEntry::MergeIntoOther do
  let(:type) { %i[anime manga ranobe].sample }

  let(:entry_1) do
    create type, :with_topics,
      russian: 'zxc',
      synonyms: %w[synonym_1 synonym_3]
  end
  let(:entry_2) do
    create type,
      russian: '',
      synonyms: %w[synonym_2]
  end
  let(:entry_3) { create type }

  let!(:user_1_rate_1) do
    create :user_rate, user_1_rate_1_status, target: entry_1, user: user_1
  end
  let(:user_1_rate_1_status) { :planned }
  let!(:user_1_rate_2) do
    create :user_rate, user_1_rate_2_status, target: entry_2, user: user_1
  end
  let(:user_1_rate_2_status) { :planned }
  let!(:user_2_rate_1) { create :user_rate, target: entry_1, user: user_2 }

  let!(:user_1_rate_log_1) { create :user_rate_log, target: entry_1, user: user_1 }
  let!(:user_1_rate_log_2) { create :user_rate_log, target: entry_2, user: user_1 }
  let!(:user_2_rate_log_1) { create :user_rate_log, target: entry_1, user: user_2 }

  let!(:user_1_history_1) { create :user_history, target: entry_1, user: user_1 }
  let!(:user_1_history_2) { create :user_history, target: entry_2, user: user_1 }
  let!(:user_2_history_1) { create :user_history, target: entry_1, user: user_2 }

  let!(:topic_1) { create :topic, linked: entry_1 }
  let!(:topic_2) { create :topic, linked: entry_1, generated: true }

  let!(:comment_1) { create :comment, :with_increment_comments, commentable: entry_1.maybe_topic(:ru) }

  let!(:review) { create :review, target: entry_1 }

  let(:collection) { create :collection }
  let!(:collection_link) { create :collection_link, linked: entry_1, collection: collection }

  let!(:version) { create :version, item: entry_1 }

  let(:club) { create :club }
  let!(:club_link) { create :club_link, linked: entry_1, club: club }

  let(:cosplay_gallery) { create :cosplay_gallery }
  let!(:cosplay_gallery_link) do
    create :cosplay_gallery_link, linked: entry_1, cosplay_gallery: cosplay_gallery
  end

  let!(:recommendation_ignore) { create :recommendation_ignore, target: entry_1 }

  let!(:contest) { create :contest }
  let!(:contest_link) { create :contest_link, linked: entry_1, contest: contest }
  let!(:contest_winner) { create :contest_winner, item: entry_1, contest: contest }
  let!(:contest_match_1) { create :contest_match, left: entry_1, right: entry_3 }
  let!(:contest_match_2) do
    create :contest_match, left: entry_3, right: entry_1, winner_id: entry_1.id
  end

  let!(:anime_link) do
    create :anime_link, anime: entry_1, identifier: 'zxc' if type == :anime
  end

  let!(:favourite_1_1) do
    create :favourite,
      linked_id: entry_1.id,
      linked_type: entry_1.class.name,
      user: user_1
  end
  let!(:favourite_1_2) do
    create :favourite,
      linked_id: entry_2.id,
      linked_type: entry_2.class.name,
      user: user_1
  end
  let!(:favourite_2_1) do
    create :favourite,
      linked_id: entry_1.id,
      linked_type: entry_1.class.name,
      user: user_2
  end

  let!(:external_link_1_1) { create :external_link, entry: entry_1, url: 'https://a.com/' }
  let!(:external_link_1_2) { create :external_link, entry: entry_1, url: 'http://b.com' }
  let!(:external_link_2_1) { create :external_link, entry: entry_2, url: 'http://a.com' }

  subject! { described_class.call entry: entry_1, other: entry_2 }

  it do
    expect(entry_2.russian).to eq entry_1.russian
    expect(entry_2.synonyms).to eq %w[synonym_1 synonym_2 synonym_3]

    expect { entry_1.reload }.to raise_error ActiveRecord::RecordNotFound

    expect { user_1_rate_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_1_rate_log_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_1_history_1.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(user_1_rate_2.reload).to be_persisted
    expect(user_1_rate_log_2.reload).to be_persisted
    expect(user_1_history_2.reload).to be_persisted

    expect(user_2_rate_1.reload.target).to eq entry_2
    expect(user_2_rate_log_1.reload.target).to eq entry_2
    expect(user_2_history_1.reload.target).to eq entry_2

    expect(topic_1.reload.linked).to eq entry_2
    expect { topic_2.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(comment_1.reload.commentable).to eq entry_2.maybe_topic(:ru)
    expect(entry_2.maybe_topic(:ru).comments_count).to eq 1

    expect(review.reload.target).to eq entry_2
    expect(collection_link.reload.linked).to eq entry_2
    expect(version.reload.item).to eq entry_2
    expect(club_link.reload.linked).to eq entry_2
    expect(cosplay_gallery_link.reload.linked).to eq entry_2
    expect(recommendation_ignore.reload.target).to eq entry_2

    expect(contest_link.reload.linked).to eq entry_2
    expect(contest_winner.reload.item).to eq entry_2
    expect(contest_match_1.reload.left).to eq entry_2
    expect(contest_match_2.reload.right).to eq entry_2
    expect(contest_match_2.winner_id).to eq entry_2.id

    if entry_1.respond_to? :anime_links
      expect(anime_link.reload.anime).to eq entry_2
    end

    expect { favourite_1_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(favourite_2_1.reload.linked).to eq entry_2

    expect { external_link_1_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(external_link_1_2.reload.entry).to eq entry_2
  end

  describe 'user_rate' do
    context 'entry_1 is completed' do
      let(:user_1_rate_1_status) { :completed }

      it do
        expect(user_1_rate_1.reload.target).to eq entry_2
        expect(user_1_rate_log_1.reload.target).to eq entry_2
        expect(user_1_history_1.reload.target).to eq entry_2

        expect { user_1_rate_2.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { user_1_rate_log_2.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { user_1_history_2.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      context 'no entry_2 rate' do
        let!(:user_1_rate_2) { nil }
        let!(:user_1_rate_log_2) { nil }
        let!(:user_1_history_2) { nil }

        it do
          expect(user_1_rate_1.reload.target).to eq entry_2
          expect(user_1_rate_log_1.reload.target).to eq entry_2
          expect(user_1_history_1.reload.target).to eq entry_2
        end
      end

      context 'entry_2 is completed' do
        let(:user_1_rate_2_status) { :completed }

        it do
          expect { user_1_rate_1.reload }.to raise_error ActiveRecord::RecordNotFound
          expect { user_1_rate_log_1.reload }.to raise_error ActiveRecord::RecordNotFound
          expect { user_1_history_1.reload }.to raise_error ActiveRecord::RecordNotFound

          expect(user_1_rate_2.reload).to be_persisted
          expect(user_1_rate_log_2.reload).to be_persisted
          expect(user_1_history_2.reload).to be_persisted
        end
      end
    end
  end
end
