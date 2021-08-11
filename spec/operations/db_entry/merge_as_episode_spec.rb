describe DbEntry::MergeAsEpisode do
  subject do
    described_class.call(
      entry: entry,
      other: other,
      episode: episode,
      episode_field: episode_field
    )
  end
  let(:episode) { 3 }
  let(:type) { %i[anime manga ranobe].sample }

  let(:entry) do
    create type, :with_topics,
      russian: 'zxc',
      synonyms: %w[synonym_1 synonym_3],
      episode_field => entry_episodes
  end
  let(:entry_episodes) { 3 }
  let(:other) do
    create type,
      russian: '',
      synonyms: %w[synonym_2],
      episode_field => other_episodes
  end
  let(:other_episodes) { 5 }
  let(:entry_3) { create type }

  let!(:user_1_rate_log_entry) { create :user_rate_log, target: entry, user: user_1 }
  let!(:user_1_rate_log_other) { create :user_rate_log, target: other, user: user_1 }
  let!(:user_2_rate_log_entry) { create :user_rate_log, target: entry, user: user_2 }

  let!(:user_1_history_entry) { create :user_history, target: entry, user: user_1 }
  let!(:user_1_history_other) { create :user_history, target: other, user: user_1 }
  let!(:user_2_history_entry) { create :user_history, target: entry, user: user_2 }

  let!(:topic_1) { create :topic, linked: entry }
  let!(:topic_2) { create :topic, linked: entry, generated: true }

  let!(:comment_1) { create :comment, :with_increment_comments, commentable: entry.maybe_topic(:ru) }

  let!(:review) { create :review, target: entry }

  let(:collection) { create :collection }
  let!(:collection_link) { create :collection_link, linked: entry, collection: collection }

  let!(:version) { create :version, item: entry }

  let(:club) { create :club }
  let!(:club_link) { create :club_link, linked: entry, club: club }

  let(:cosplay_gallery) { create :cosplay_gallery }
  let!(:cosplay_gallery_link) do
    create :cosplay_gallery_link, linked: entry, cosplay_gallery: cosplay_gallery
  end

  let!(:recommendation_ignore) { create :recommendation_ignore, target: entry }

  let!(:contest) { create :contest }
  let!(:contest_link) { create :contest_link, linked: entry, contest: contest }
  let!(:contest_winner) { create :contest_winner, item: entry, contest: contest }
  let!(:contest_match_1) { create :contest_match, left: entry, right: entry_3 }
  let!(:contest_match_2) do
    create :contest_match, left: entry_3, right: entry, winner_id: entry.id
  end

  let!(:anime_link) do
    create :anime_link, anime: entry, identifier: 'zxc' if type == :anime
  end

  let!(:favourite_1_1) do
    create :favourite,
      linked_id: entry.id,
      linked_type: entry.class.name,
      user: user_1
  end
  let!(:favourite_1_2) do
    create :favourite,
      linked_id: other.id,
      linked_type: other.class.name,
      user: user_1
  end
  let!(:favourite_2_1) do
    create :favourite,
      linked_id: entry.id,
      linked_type: entry.class.name,
      user: user_2
  end

  let!(:external_link_1_1) { create :external_link, entry: entry, url: 'https://a.com/' }
  let!(:external_link_1_2) { create :external_link, entry: entry, url: 'http://b.com' }
  let!(:external_link_2_1) { create :external_link, entry: other, url: 'http://a.com' }

  let!(:user_rate_entry) { nil }
  let!(:user_rate_other) { nil }

  let(:episode_field) { type == :anime ? :episodes : :volumes }

  it do
    is_expected.to eq true

    expect(other.russian).to eq ''
    expect(other.synonyms).to eq %w[synonym_2]

    expect { entry.reload }.to raise_error ActiveRecord::RecordNotFound

    expect { user_1_rate_log_entry.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_1_history_entry.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(user_1_rate_log_other.reload).to be_persisted
    expect(user_1_history_other.reload).to be_persisted

    expect { user_2_rate_log_entry.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_2_history_entry.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(topic_1.reload.linked).to eq other
    expect { topic_2.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(comment_1.reload.commentable).to eq other.maybe_topic(:ru)
    expect(other.maybe_topic(:ru).comments_count).to eq 1

    expect(review.reload.target).to eq other
    expect(collection_link.reload.linked).to eq other
    expect(version.reload.item).to eq other
    expect(club_link.reload.linked).to eq other
    expect(cosplay_gallery_link.reload.linked).to eq other
    expect(recommendation_ignore.reload.target).to eq other

    expect(contest_link.reload.linked).to eq other
    expect(contest_winner.reload.item).to eq other
    expect(contest_match_1.reload.left).to eq other
    expect(contest_match_2.reload.right).to eq other
    expect(contest_match_2.winner_id).to eq other.id

    if entry.respond_to? :anime_links
      expect(anime_link.reload.anime).to eq other
    end

    expect { favourite_1_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(favourite_2_1.reload.linked).to eq other

    expect { external_link_1_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(external_link_1_2.reload.entry).to eq other
  end

  context 'user_rates' do
    let!(:user_rate_entry) do
      create :user_rate,
        target: entry,
        user: user_1,
        status: user_rate_entry_status,
        episode_field => user_rate_entry_episodes
    end
    let(:user_rate_entry_status) { 'watching' }
    let(:user_rate_entry_episodes) { 2 }

    let!(:user_rate_other) do
      create :user_rate,
        target: other,
        user: user_1,
        status: user_rate_other_status,
        episode_field => user_rate_other_episodes
    end
    let(:user_rate_other_status) { 'watching' }
    let(:user_rate_other_episodes) { 4 }

    context 'planned -> *' do
      let(:user_rate_entry_status) { 'planned' }

      it 'ignored' do
        is_expected.to eq true

        expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(user_rate_other.reload).to have_attributes(
          status: user_rate_other_status,
          episode_field => user_rate_other_episodes
        )
      end
    end

    context 'completed/watching -> nil' do
      let!(:user_rate_other) { nil }

      %w[watching on_hold dropped].each do |status|
        context status do
          let(:user_rate_entry_status) { status }
          let(:final_episodes_num) { 4 }
          it do
            expect { subject }.to_not change UserRate, :count
            expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
            expect(final_episodes_num).to eq 4
            expect(final_episodes_num).to eq episode + user_rate_entry.send(episode_field) - 1
            expect(UserRate.order(id: :desc).first).to have_attributes(
              status: status,
              episode_field => final_episodes_num
            )
          end
        end
      end

      %w[planned completed].each do |status|
        context status do
          let(:user_rate_entry_status) { 'watching' }
          it do
            expect { subject }.to_not change UserRate, :count
            expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
            expect(UserRate.order(id: :desc).first).to have_attributes(
              status: 'watching',
              episode_field => 4
            )
          end
        end
      end
    end

    context 'nil -> *' do
      let!(:user_rate_entry) { nil }

      it do
        expect { subject }.to_not change UserRate, :count
        expect(user_rate_other.reload).to be_persisted
      end
    end

    context 'entry.episodes=2' do
      let(:entry_episodes) { 2 }

      context 'other.episodes=6' do
        let(:other_episodes) { 6 }

        context 'user_rate_entry.episodes=2' do
          let(:user_rate_entry_episodes) { 2 }

          context 'user_rate_other.episodes=4' do
            let(:user_rate_entry_episodes) { 4 }

            describe 'user_rate' do
              it do
                is_expected.to eq true
              end

              # context 'rate_other episodes >= entry episodes + rate_entry episodes' do
              #   let(:user_rate_entry_episodes) { 2 }
              #   let(:episode) { 2 }
              #   let(:user_rate_other_episodes) { 4 }
              # 
              #   it do
              #     is_expected.to eq true
              #     expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
              #     expect(user_rate_other.reload).to have_attributes(
              #       status: user_rate_other_status,
              #       episode_field => user_rate_other_episodes
              #     )
              #   end
              # end

              context 'rate_other episodes < entry episodes + rate_entry episodes' do
                # context 'rate_entry episodes + rate_other episoes = completed', :focus do
                #   let(:other_episodes) { 6 }
                #   it do
                #     ap "entry.episodes #{entry.send(episode_field)}"
                #     ap "other.episodes #{other.send(episode_field)}"
                #     ap "user_rate_entry.episodes #{user_rate_entry.send(episode_field)}"
                #     ap "user_rate_other.episodes #{user_rate_other.send(episode_field)}"
                #     ap "episodes #{episodes}"
                #     is_expected.to eq true
                #     expect(user_rate_other.reload).to have_attributes(
                #       status: 'complated',
                #       episode_field => other_episodes
                #     )
                #   end
                # end

                # context '-> not completed' do
                #   context 'full apply' do
                #     let(:other_episodes) { 7 }
                # 
                #     it do
                #       expect(user_rate_other.reload).to have_attributes(
                #         status: 'watching',
                #         episode_field => 6
                #       )
                #     end
                #   end
                # 
                #   context 'partial apply' do
                #     let(:user_rate_other_episodes) { 5 }
                # 
                #     it do
                #       expect(user_rate_other.reload).to have_attributes(
                #         status: 'watching',
                #         episode_field => 6
                #       )
                #     end
                #   end
                # end
              end
            end
          end
        end
      end
    end
  end
end
