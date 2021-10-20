describe DbEntry::MergeAsEpisode do
  subject do
    described_class.call(
      entry: entry,
      other: other,
      as_episode: as_episode,
      episode_label: episode_label,
      episode_field: episode_field
    )
  end
  let(:as_episode) { 3 }
  let(:type) { %i[anime manga ranobe].sample }

  let(:entry) do
    create type, :with_topics, {
      **(type == :anime ? {
        fansubbers: %w[fansubber_1 fansubber_3],
        fandubbers: %w[fandubber_1 fandubber_3],
        coub_tags: %w[coub_tag_1 coub_tag_3]
      } : {}),
      russian: 'zxc',
      episode_field => entry_episodes,
      synonyms: %w[synonym_1 synonym_3]
    }
  end
  let(:entry_episodes) { 3 }
  let(:other) do
    create type, {
      **(type == :anime ? {
        fansubbers: %w[fansubber_2],
        fandubbers: %w[fandubber_2],
        coub_tags: %w[coub_tag_2]
      } : {}),
      russian: '',
      episode_field => other_episodes,
      synonyms: %w[русское_название_2 русское_название_1 synonym_2]
    }
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

  let!(:critique) { create :critique, target: entry }

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
  let(:episode_label) { ['', nil].sample }

  it do
    is_expected.to eq true

    expect(other.russian).to eq ''
    expect(other.synonyms).to eq %w[русское_название_2 русское_название_1 zxc synonym_2]
    if type == :anime
      expect(other.fansubbers).to eq %w[fansubber_1 fansubber_2 fansubber_3]
      expect(other.fandubbers).to eq %w[fandubber_1 fandubber_2 fandubber_3]
      expect(other.coub_tags).to eq %w[coub_tag_1 coub_tag_2 coub_tag_3]
    end

    expect { entry.reload }.to raise_error ActiveRecord::RecordNotFound

    expect { user_1_rate_log_entry.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_1_history_entry.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(user_1_rate_log_other.reload).to be_persisted
    expect(user_1_history_other.reload).to be_persisted

    expect { user_2_rate_log_entry.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_2_history_entry.reload }.to raise_error ActiveRecord::RecordNotFound

    expect { topic_1.reload.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { topic_2.reload }.to raise_error ActiveRecord::RecordNotFound

    expect { comment_1.reload.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(other.maybe_topic(:ru).comments_count).to eq 0

    expect(critique.reload.target).to eq other
    expect { collection_link.reload }.to raise_error ActiveRecord::RecordNotFound

    expect { version.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { club_link.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { cosplay_gallery_link.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { recommendation_ignore.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(contest_link.reload.linked).to eq other
    expect(contest_winner.reload.item).to eq other
    expect(contest_match_1.reload.left).to eq other
    expect(contest_match_2.reload.right).to eq other
    expect(contest_match_2.winner_id).to eq other.id

    if entry.respond_to? :anime_links
      expect { anime_link.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    expect { favourite_1_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { favourite_2_1.reload.reload }.to raise_error ActiveRecord::RecordNotFound

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
        episode_field => user_rate_other_episodes,
        text: user_rate_other_text
    end
    let(:user_rate_other_status) do
      user_rate_other_episodes == other_episodes ?
        'completed' :
        'watching'
    end
    let(:user_rate_other_episodes) { 4 }
    let(:user_rate_other_text) { '' }

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
      let(:new_user_rate) { UserRate.order(id: :desc).first }

      context 'as_episode = 1' do
        let(:as_episode) { 1 }
        let(:user_rate_entry_status) { :watching }
        let(:final_episodes_num) { 2 }

        it do
          expect { subject }.to_not change UserRate, :count
          expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
          expect(final_episodes_num).to eq 2
          expect(final_episodes_num).to eq as_episode + user_rate_entry.send(episode_field) - 1
          expect(new_user_rate).to have_attributes(
            status: 'watching',
            episode_field => final_episodes_num,
            text: "✅ #{described_class::EPISODE_LABEL[episode_field]} 1-2 #{entry.name} (#{entry.russian})"
          )
        end

        context 'episode label' do
          let(:episode_label) { 'zxc' }
          it do
            expect { subject }.to_not change UserRate, :count
            expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
            expect(final_episodes_num).to eq 2
            expect(final_episodes_num).to eq as_episode + user_rate_entry.send(episode_field) - 1
            expect(new_user_rate).to have_attributes(
              status: 'watching',
              episode_field => final_episodes_num,
              text: "✅ #{episode_label} #{entry.name} (#{entry.russian})"
            )
          end
        end
      end

      context 'as_episode = 2' do
        let(:as_episode) { 2 }
        let(:user_rate_entry_status) { :watching }
        let(:final_episodes_num) { 3 }

        it do
          expect { subject }.to_not change UserRate, :count
          expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
          expect(new_user_rate).to have_attributes(
            status: 'watching',
            episode_field => 0,
            text: "✅ #{described_class::EPISODE_LABEL[episode_field]} 2-3 #{entry.name} (#{entry.russian})"
          )
        end
      end

      describe 'status mapping' do
        %w[watching on_hold dropped].each do |status|
          context status do
            let(:user_rate_entry_status) { status }

            it do
              expect { subject }.to_not change UserRate, :count
              expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
              expect(new_user_rate).to have_attributes(
                status: status
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
              expect(new_user_rate).to have_attributes(
                status: 'watching'
              )
            end
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

    context 'as_episode = 4' do
      let(:as_episode) { 4 }
      let(:merge_text) do
        "✅ #{described_class::EPISODE_LABEL[episode_field]} "\
          "#{merge_text_episodes} #{entry.name} (#{entry.russian})"
      end
      let(:merge_text_episodes) { '4' }

      context 'entry.episodes = 0 or 1' do
        let(:entry_episodes) { [0, 1].sample }

        context 'other.episodes = 6' do
          let(:other_episodes) { 6 }

          context 'user_rate_entry.episodes = 1' do
            let(:user_rate_entry_episodes) { 1 }

            context 'user_rate_other.episodes = AS_EPISODE - 2 (2)' do
              let(:user_rate_other_episodes) { as_episode - 2 }
              let(:user_rate_other_text) { 'zxc' }

              it do
                is_expected.to eq true
                expect(user_rate_other_episodes).to eq 2
                expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
                expect(user_rate_other.reload).to have_attributes(
                  episode_field => user_rate_other_episodes,
                  status: 'watching',
                  text: "zxc\n" + merge_text
                )
              end
            end

            context 'user_rate_other.episodes = AS_EPISODE - 1 (3)' do
              let(:user_rate_other_episodes) { as_episode - 1 }

              it do
                is_expected.to eq true
                expect(user_rate_other_episodes).to eq 3
                expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
                expect(user_rate_other.reload).to have_attributes(
                  episode_field => 4,
                  status: 'watching',
                  text: merge_text
                )
              end

              context 'mismatched one_shot episode_field' do
                let(:type) { :manga }
                let(:user_rate_entry_status) { :completed }

                let!(:user_rate_entry) do
                  create :user_rate,
                    target: entry,
                    user: user_1,
                    status: user_rate_entry_status,
                    chapters: user_rate_entry_episodes
                end

                it do
                  is_expected.to eq true
                  expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
                  expect(user_rate_other.reload).to have_attributes(
                    episode_field => 4,
                    status: 'watching',
                    text: merge_text
                  )
                end
              end
            end
          end

          context 'user_rate_entry.episodes = 0' do
            let(:user_rate_entry_episodes) { 0 }

            context 'user_rate_other.episodes = AS_EPISODE - 1 (3)' do
              let(:user_rate_other_episodes) { as_episode - 1 }

              it do
                is_expected.to eq true
                expect(user_rate_other_episodes).to eq 3
                expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
                expect(user_rate_other.reload).to have_attributes(
                  episode_field => user_rate_other_episodes,
                  status: 'watching',
                  text: ''
                )
              end
            end
          end
        end
      end

      context 'entry.episodes = 3' do
        let(:entry_episodes) { 3 }

        context 'other.episodes = 6' do
          let(:other_episodes) { 6 }

          context 'user_rate_entry.episodes = 3' do
            let(:merge_text_episodes) { '4-6' }
            let(:user_rate_entry_episodes) { 3 }

            context 'user_rate_other.episodes = 2' do
              let(:user_rate_other_episodes) { 2 }

              it do
                is_expected.to eq true
                expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
                expect(user_rate_other.reload).to have_attributes(
                  episode_field => 2,
                  status: 'watching',
                  text: merge_text
                )
              end
            end

            context 'user_rate_other.episodes = 3' do
              let(:user_rate_other_episodes) { 3 }

              it do
                is_expected.to eq true
                expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
                expect(user_rate_other.reload).to have_attributes(
                  episode_field => 6,
                  status: 'completed',
                  text: merge_text
                )
              end
            end

            context 'user_rate_other.episodes = 4' do
              let(:user_rate_other_episodes) { 4 }

              it do
                is_expected.to eq true
                expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
                expect(user_rate_other.reload).to have_attributes(
                  episode_field => 6,
                  status: 'completed',
                  text: merge_text
                )
              end
            end

            context 'user_rate_other.episodes = 6' do
              let(:user_rate_other_episodes) { 6 }

              it do
                is_expected.to eq true
                expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
                expect(user_rate_other.reload).to have_attributes(
                  episode_field => 6,
                  status: 'completed',
                  text: ''
                )
              end
            end
          end

          context 'user_rate_entry.episodes = 2' do
            let(:user_rate_entry_episodes) { 2 }

            context 'user_rate_other.episodes = [3-5]' do
              let(:user_rate_other_episodes) { [3, 4, 5].sample }

              it do
                is_expected.to eq true
                expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
                expect(user_rate_other.reload).to have_attributes(
                  episode_field => 5,
                  status: 'watching'
                )
              end
            end

            context 'user_rate_other.episodes = [0, 1, 2]' do
              let(:user_rate_other_episodes) { [0, 1, 2].sample }

              it do
                is_expected.to eq true
                expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
                expect(user_rate_other.reload).to have_attributes(
                  episode_field => user_rate_other_episodes,
                  status: 'watching'
                )
              end
            end
          end
        end
      end
    end

    context 'as_episode = 0' do
      let(:as_episode) { 0 }
      let(:user_rate_entry_episodes) { 1 }
      let(:user_rate_other_episodes) { [1, 2].sample }

      context 'has other_rate' do
        context 'user_rate_other_episodes == 0' do
          let(:user_rate_other_episodes) { 0 }
          it do
            is_expected.to eq true
            expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
            expect(user_rate_other.reload).to have_attributes(
              episode_field => user_rate_other_episodes,
              status: 'watching',
              text: "✅ #{entry.name} (#{entry.russian})"
            )
          end
        end

        context 'user_rate_other_episodes > 0' do
          it do
            is_expected.to eq true
            expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
            expect(user_rate_other.reload).to have_attributes(
              episode_field => user_rate_other_episodes,
              status: 'watching',
              text: ''
            )
          end
        end
      end

      context 'no other_rate' do
        let!(:user_rate_other) { nil }
        let(:new_user_rate) { UserRate.order(id: :desc).first }

        it do
          is_expected.to eq true
          expect { user_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
          expect(new_user_rate).to have_attributes(
            status: 'watching',
            episode_field => 0,
            text: "✅ #{entry.name} (#{entry.russian})"
          )
        end
      end
    end
  end
end
