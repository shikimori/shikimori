describe DbEntry::MergeAsEpisode do
  let(:type) { %i[anime manga ranobe].sample }

  let(:entry_1) do
    create type, :with_topics,
      russian: 'zxc',
      synonyms: %w[synonym_1 synonym_3],
      episode_field => entry_1_episodes
  end
  let(:entry_1_episodes) { 3 }
  let(:entry_2) do
    create type,
      russian: '',
      synonyms: %w[synonym_2],
      episode_field => entry_2_episodes
  end
  let(:entry_2_episodes) { 5 }
  let(:entry_3) { create type }

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

  let!(:user_rate_1) { nil }
  let!(:user_rate_2) { nil }

  subject! do
    described_class.call(
      entry: entry_1,
      other: entry_2,
      episode: episode,
      episode_field: episode_field
    )
  end
  let(:episode) { 3 }
  let(:episode_field) { type == :anime ? :episodes : :volumes }

  it do
    expect(entry_2.russian).to eq ''
    expect(entry_2.synonyms).to eq %w[synonym_2]

    expect { entry_1.reload }.to raise_error ActiveRecord::RecordNotFound

    expect { user_1_rate_log_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_1_history_1.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(user_1_rate_log_2.reload).to be_persisted
    expect(user_1_history_2.reload).to be_persisted

    expect { user_2_rate_log_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_2_history_1.reload }.to raise_error ActiveRecord::RecordNotFound

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

  describe 'user_rate', :focus do
    let!(:user_rate_1) do
      create :user_rate,
        target: entry_1,
        user: user_1,
        status: user_rate_1_status,
        episode_field => user_rate_1_episodes
    end
    let(:user_rate_1_status) { 'watching' }
    let(:user_rate_1_episodes) { 2 }

    let!(:user_rate_2) do
      create :user_rate,
        target: entry_2,
        user: user_1,
        status: user_rate_2_status,
        episode_field => user_rate_2_episodes
    end
    let(:user_rate_2_status) { 'watching' }
    let(:user_rate_2_episodes) { 3 }

    context 'planned -> *' do
      let(:user_rate_1_status) { 'planned' }

      it 'ignored' do
        expect { user_rate_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(user_rate_2.reload).to have_attributes(
          status: user_rate_2_status,
          episode_field => user_rate_2_episodes
        )
      end
    end

    context 'rate_2 episodes >= entry episodes + rate_1 episodes' do
      let(:user_rate_1_episodes) { 2 }
      let(:episode) { 2 }
      let(:user_rate_2_episodes) { 4 }

      it do
        expect { user_rate_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(user_rate_2.reload).to have_attributes(
          status: user_rate_2_status,
          episode_field => user_rate_2_episodes
        )
      end
    end

    context 'rate_2 episodes < entry episodes + rate_1 episodes' do
      context '-> completed' do
        it do
          expect(user_rate_2.reload).to have_attributes(
            status: 'complated',
            episode_field => 6
          )
        end
      end

      context '-> not completed' do
        context 'full apply' do
          let(:entry_2_episodes) { 7 }

          it do
            expect(user_rate_2.reload).to have_attributes(
              status: 'watching',
              episode_field => 6
            )
          end
        end

        context 'partial apply' do
          let(:user_rate_2_episodes) { 5 }

          it do
            expect(user_rate_2.reload).to have_attributes(
              status: 'watching',
              episode_field => 6
            )
          end
        end
      end
    end
  end
end
