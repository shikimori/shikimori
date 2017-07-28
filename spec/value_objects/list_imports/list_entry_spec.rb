describe ListImports::ListEntry do
  let(:entry) do
    ListImports::ListEntry.new(
      target_title: target_title,
      target_id: target_id,
      target_type: target_type,
      score: score,
      status: status,
      rewatches: rewatches,
      episodes: episodes,
      volumes: volumes,
      chapters: chapters,
      text: text
    )
  end
  let(:target_title) { 'test' }
  let(:target_id) { anime.id }
  let(:target_type) { Anime.name }
  let(:score) { 5 }
  let(:status) { :completed }
  let(:rewatches) { 1 }
  let(:episodes) { 2 }
  let(:volumes) { 3 }
  let(:chapters) { 4 }
  let(:text) { 'test' }

  let(:anime) { build_stubbed :anime }

  describe '#export' do
    subject! { entry.export user_rate }

    context 'user_rate with target' do
      let(:user_rate) { build :user_rate, target: anime }

      it do
        is_expected.to eq user_rate
        is_expected.to have_attributes(
          status: status.to_s,
          score: score,
          episodes: episodes,
          rewatches: rewatches,
          volumes: 0,
          chapters: 0
        )
      end
    end

    context 'user_rate wo target' do
      let(:user_rate) { build :user_rate, :planned, target: nil }
      it do
        is_expected.to be_nil
        expect(user_rate).to have_attributes(
          status: 'planned',
          score: 0,
          episodes: 0,
          rewatches: 0
        )
      end
    end
  end

  describe '#build' do
    let(:user_rate) { build_stubbed :user_rate, target: anime }
    let(:anime) { build_stubbed :anime }
    subject! { ListImports::ListEntry.build user_rate }

    it do
      is_expected.to eq ListImports::ListEntry.new(
        target_title: user_rate.target&.name,
        target_id: user_rate.target_id,
        target_type: user_rate.target_type,
        score: user_rate.score,
        status: user_rate.status,
        rewatches: user_rate.rewatches,
        episodes: user_rate.episodes,
        volumes: user_rate.volumes,
        chapters: user_rate.chapters,
        text: user_rate.text
      )
    end
  end
end
