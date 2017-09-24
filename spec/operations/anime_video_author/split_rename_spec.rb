# frozen_string_literal: true

describe AnimeVideoAuthor::SplitRename do
  include_context :timecop

  let! :anime_video_1 do
    create :anime_video, kind_1,
      anime: anime_1,
      author: author_1,
      updated_at: 1.day.ago
  end
  let! :anime_video_2 do
    create :anime_video, kind_2,
      anime: anime_2,
      author: author_2,
      updated_at: 1.day.ago
  end
  let! :anime_video_3 do
    create :anime_video, kind_3,
      anime: anime_3,
      author: author_3,
      updated_at: 1.day.ago
  end
  let!(:anime_video_4) { create :anime_video, updated_at: 1.day.ago }

  let!(:author_1) { create :anime_video_author, name: 'zxc' }
  let!(:author_2) { create :anime_video_author, name: 'vbn' }
  let!(:author_3) { create :anime_video_author, name: 'mkl' }

  let(:kind_1) { :subtitles }
  let(:kind_2) { :unknown }
  let(:kind_3) { :fandub }

  let(:anime_1) { build_stubbed :anime }
  let(:anime_2) { build_stubbed :anime }
  let(:anime_3) { build_stubbed :anime }

  before { allow(AnimeVideoAuthor::Rename).to receive :call }

  subject do
    AnimeVideoAuthor::SplitRename.call(
      model: author_1,
      anime_id: anime_id,
      kind: kind,
      new_name: new_name
    )
  end
  let(:anime_id) { nil }
  let(:kind) { nil }

  let(:new_author) { AnimeVideoAuthor.find_by name: new_name }

  context 'not changed name' do
    let(:new_name) { author_1.name }

    it do
      expect { subject }.to_not change AnimeVideoAuthor, :count

      expect(AnimeVideoAuthor::Rename).to_not have_received :call

      expect(anime_video_1.reload.author_name).to eq author_1.name
      expect(anime_video_1.updated_at).to be_within(0.1).of(1.day.ago)

      expect(anime_video_2.reload.author_name).to eq author_2.name
      expect(anime_video_2.updated_at).to be_within(0.1).of(1.day.ago)

      expect(anime_video_3.reload.author_name).to eq author_3.name
      expect(anime_video_3.updated_at).to be_within(0.1).of(1.day.ago)

      expect(anime_video_4.updated_at).to be_within(0.1).of(1.day.ago)
    end
  end

  context 'changed name' do
    let(:new_name) { author_1.name + 'qwe' }

    context 'matched all of author videos' do
      it do
        expect { subject }.to_not change AnimeVideoAuthor, :count
        expect(AnimeVideoAuthor::Rename)
          .to have_received(:call)
          .with author_1, new_name
      end
    end

    context 'matched some of author videos' do
      let(:author_2) { author_1 }

      context 'blank name' do
        let(:anime_id) { anime_1.id }
        let(:new_name) { ['', nil].sample }

        it do
          expect { subject }.to_not change AnimeVideoAuthor, :count
          expect(AnimeVideoAuthor::Rename).to_not have_received :call

          expect(anime_video_1.reload.author).to be_nil
          expect(anime_video_1.updated_at).to be_within(0.1).of(Time.zone.now)

          expect(anime_video_2.reload.author).to eq author_2
          expect(anime_video_2.updated_at).to be_within(0.1).of(1.day.ago)

          expect(anime_video_3.reload.author).to eq author_3
          expect(anime_video_3.updated_at).to be_within(0.1).of(1.day.ago)

          expect(anime_video_4.updated_at).to be_within(0.1).of(1.day.ago)
        end
      end

      context 'filter by anime_id' do
        let(:anime_id) { anime_1.id }

        it do
          expect { subject }.to change(AnimeVideoAuthor, :count).by 1
          expect(AnimeVideoAuthor::Rename).to_not have_received :call

          expect(anime_video_1.reload.author).to eq new_author
          expect(anime_video_1.updated_at).to be_within(0.1).of(Time.zone.now)

          expect(anime_video_2.reload.author).to eq author_2
          expect(anime_video_2.updated_at).to be_within(0.1).of(1.day.ago)

          expect(anime_video_3.reload.author).to eq author_3
          expect(anime_video_3.updated_at).to be_within(0.1).of(1.day.ago)

          expect(anime_video_4.updated_at).to be_within(0.1).of(1.day.ago)
        end
      end

      context 'filter by kind' do
        let(:kind) { kind_1 }

        it do
          expect { subject }.to change(AnimeVideoAuthor, :count).by 1
          expect(AnimeVideoAuthor::Rename).to_not have_received :call

          expect(anime_video_1.reload.author).to eq new_author
          expect(anime_video_1.updated_at).to be_within(0.1).of(Time.zone.now)

          expect(anime_video_2.reload.author).to eq author_2
          expect(anime_video_2.updated_at).to be_within(0.1).of(1.day.ago)

          expect(anime_video_3.reload.author).to eq author_3
          expect(anime_video_3.updated_at).to be_within(0.1).of(1.day.ago)

          expect(anime_video_4.updated_at).to be_within(0.1).of(1.day.ago)
        end
      end

      context 'filter by anime_id + kind' do
        let(:anime_id) { anime_1.id }
        let(:kind) { kind_1 }
        let(:author_3) { author_1 }

        it do
          expect { subject }.to change(AnimeVideoAuthor, :count).by 1
          expect(AnimeVideoAuthor::Rename).to_not have_received :call

          expect(anime_video_1.reload.author).to eq new_author
          expect(anime_video_1.updated_at).to be_within(0.1).of(Time.zone.now)

          expect(anime_video_2.reload.author).to eq author_2
          expect(anime_video_3.updated_at).to be_within(0.1).of(1.day.ago)

          expect(anime_video_3.reload.author).to eq author_3
          expect(anime_video_3.updated_at).to be_within(0.1).of(1.day.ago)

          expect(anime_video_4.updated_at).to be_within(0.1).of(1.day.ago)
        end
      end
    end
  end
end
