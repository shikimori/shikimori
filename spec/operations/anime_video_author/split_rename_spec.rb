# frozen_string_literal: true

describe AnimeVideoAuthor::SplitRename do
  include_context :timecop

  let! :anime_video_1 do
    create :anime_video,
      anime: anime_1,
      author: author_1,
      updated_at: 1.day.ago
  end
  let! :anime_video_2 do
    create :anime_video,
      anime: anime_2,
      author: author_1,
      updated_at: 1.day.ago
  end
  let!(:author_1) { create :anime_video_author, name: 'zxc' }
  let!(:author_2) { create :anime_video_author, name: 'vbn' }

  before { allow(AnimeVideoAuthor::Rename).to receive :call }

  subject do
    AnimeVideoAuthor::SplitRename.call(
      model: author_1,
      anime_id: anime_1.id,
      new_name: new_name
    )
  end

  context 'one anime' do
    let(:anime_1) { build_stubbed :anime }
    let(:anime_2) { anime_1 }

    context 'no changes in name' do
      let(:new_name) { author_1.name }

      it do
        expect { subject }.to_not change AnimeVideoAuthor, :count
        expect(AnimeVideoAuthor::Rename).to_not have_received :call
        expect(author_1.reload.name).to eq new_name
        expect(anime_video_1.reload.author_name).to eq author_1.name
        expect(anime_video_1.updated_at).to be_within(0.1).of(1.day.ago)
      end
    end

    context 'changed name' do
      let(:new_name) { 'zzzzzzzz' }

      it do
        expect { subject }.to_not change AnimeVideoAuthor, :count
        expect(AnimeVideoAuthor::Rename)
          .to have_received(:call)
          .with author_1, new_name
      end
    end
  end

  context 'multiple animes' do
    let(:anime_1) { build_stubbed :anime }
    let(:anime_2) { build_stubbed :anime }

    context 'no changes in name' do
      let(:new_name) { author_1.name }

      it do
        expect { subject }.to_not change AnimeVideoAuthor, :count
        expect(AnimeVideoAuthor::Rename).to_not have_received :call

        expect(author_1.reload.name).to eq new_name
        expect(anime_video_1.reload.author_name).to eq author_1.name
        expect(anime_video_1.updated_at).to be_within(0.1).of(1.day.ago)
      end
    end

    context 'no name' do
      let(:new_name) { '' }

      it do
        expect { subject }.to_not change AnimeVideoAuthor, :count
        expect(AnimeVideoAuthor::Rename).to_not have_received :call

        expect(anime_video_1.reload.author).to be_nil
        expect(anime_video_1.updated_at).to be_within(0.1).of(Time.zone.now)

        expect(anime_video_2.reload.author).to eq author_1
        expect(anime_video_2.updated_at).to be_within(0.1).of(1.day.ago)
      end
    end

    context 'another author name' do
      let(:new_name) { 'vbn' }

      it do
        expect { subject }.to_not change AnimeVideoAuthor, :count
        expect(AnimeVideoAuthor::Rename).to_not have_received :call

        expect(anime_video_1.reload.author).to eq author_2
        expect(anime_video_1.updated_at).to be_within(0.1).of(Time.zone.now)

        expect(anime_video_2.reload.author).to eq author_1
        expect(anime_video_2.updated_at).to be_within(0.1).of(1.day.ago)
      end
    end

    context 'just new name' do
      let(:new_name) { '123' }
      let(:author_3) { AnimeVideoAuthor.find_by name: new_name }

      it do
        expect { subject }.to change(AnimeVideoAuthor, :count).by 1
        expect(AnimeVideoAuthor::Rename).to_not have_received :call

        expect(anime_video_1.reload.author).to eq author_3
        expect(anime_video_1.updated_at).to be_within(0.1).of(Time.zone.now)

        expect(anime_video_2.reload.author).to eq author_1
        expect(anime_video_2.updated_at).to be_within(0.1).of(1.day.ago)

        expect(author_3).to_not eq author_1
        expect(author_3).to_not eq author_2
      end
    end
  end
end
