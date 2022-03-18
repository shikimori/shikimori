describe DbEntry::MergeIntoOther do
  let(:type) { %i[anime manga ranobe].sample }

  let(:entry) do
    create type, :with_topics, {
      **(type == :anime ? {
        fansubbers: %w[fansubber_1 fansubber_3],
        fandubbers: %w[fandubber_1 fandubber_3],
        coub_tags: %w[coub_tag_1 coub_tag_3]
      } : {}),
      russian: 'zxc',
      synonyms: %w[synonym_1 synonym_3]
    }
  end
  let(:other) do
    create type, {
      **(type == :anime ? {
        fansubbers: %w[fansubber_2],
        fandubbers: %w[fandubber_2],
        coub_tags: %w[coub_tag_2]
      } : {}),
      russian: '',
      synonyms: %w[synonym_2]
    }
  end
  let(:entry_3) { create type }

  let!(:user_1_rate_entry) do
    create :user_rate, user_1_rate_entry_status, target: entry, user: user_1
  end
  let(:user_1_rate_entry_status) { :planned }
  let!(:user_1_rate_other) do
    create :user_rate, user_1_rate_other_status, target: other, user: user_1
  end
  let(:user_1_rate_other_status) { :planned }
  let!(:user_2_rate_entry) { create :user_rate, target: entry, user: user_2 }

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
  let!(:review) { create :review, "#{entry.anime? ? :anime : :manga}": entry }

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

  subject { described_class.call entry: entry, other: other }

  it '', :focus do
    is_expected.to eq true

    expect(other.russian).to eq entry.russian
    expect(other.synonyms).to eq %w[synonym_1 synonym_2 synonym_3]
    if type == :anime
      expect(other.fansubbers).to eq %w[fansubber_1 fansubber_2 fansubber_3]
      expect(other.fandubbers).to eq %w[fandubber_1 fandubber_2 fandubber_3]
      expect(other.coub_tags).to eq %w[coub_tag_1 coub_tag_2 coub_tag_3]
    end

    expect { entry.reload }.to raise_error ActiveRecord::RecordNotFound

    expect { user_1_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_1_rate_log_entry.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_1_history_entry.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(user_1_rate_other.reload).to be_persisted
    expect(user_1_rate_log_other.reload).to be_persisted
    expect(user_1_history_other.reload).to be_persisted

    expect(user_2_rate_entry.reload.target).to eq other
    expect(user_2_rate_log_entry.reload.target).to eq other
    expect(user_2_history_entry.reload.target).to eq other

    expect(topic_1.reload.linked).to eq other
    expect { topic_2.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(comment_1.reload.commentable).to eq other.maybe_topic(:ru)
    expect(other.maybe_topic(:ru).comments_count).to eq 1

    expect(critique.reload.target).to eq other
    expect(review.reload.db_entry).to eq other
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

  describe 'user_rate' do
    context 'entry is completed' do
      let(:user_1_rate_entry_status) { :completed }

      it do
        is_expected.to eq true

        expect(user_1_rate_entry.reload.target).to eq other
        expect(user_1_rate_log_entry.reload.target).to eq other
        expect(user_1_history_entry.reload.target).to eq other

        expect { user_1_rate_other.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { user_1_rate_log_other.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { user_1_history_other.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      context 'no other rate' do
        let!(:user_1_rate_other) { nil }
        let!(:user_1_rate_log_other) { nil }
        let!(:user_1_history_other) { nil }

        it do
          is_expected.to eq true

          expect(user_1_rate_entry.reload.target).to eq other
          expect(user_1_rate_log_entry.reload.target).to eq other
          expect(user_1_history_entry.reload.target).to eq other
        end
      end

      context 'other is completed' do
        let(:user_1_rate_other_status) { :completed }

        it do
          is_expected.to eq true

          expect { user_1_rate_entry.reload }.to raise_error ActiveRecord::RecordNotFound
          expect { user_1_rate_log_entry.reload }.to raise_error ActiveRecord::RecordNotFound
          expect { user_1_history_entry.reload }.to raise_error ActiveRecord::RecordNotFound

          expect(user_1_rate_other.reload).to be_persisted
          expect(user_1_rate_log_other.reload).to be_persisted
          expect(user_1_history_other.reload).to be_persisted
        end
      end
    end
  end
end
