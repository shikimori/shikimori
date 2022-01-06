describe Topics::DecomposedBody do
  subject { Topics::DecomposedBody.from_value body }
  let(:image_1) { create :user_image }

  context 'no body' do
    let(:body) { nil }
    it do
      is_expected.to have_attributes(
        text: '',
        wall: nil,
        source: nil
      )
      expect(subject.wall_video).to be_nil
      expect(subject.wall_images).to be_empty
    end
  end

  context 'text only' do
    let(:body) do
      <<~TEXT.squish.strip
        test[image=#{image_1.id}]
      TEXT
    end

    it do
      is_expected.to have_attributes(
        text: "test[image=#{image_1.id}]",
        wall: nil,
        source: nil
      )
      expect(subject.wall_video).to be_nil
      expect(subject.wall_images).to be_empty
    end
  end

  context 'source' do
    let(:body) do
      <<~TEXT.squish.strip
        test[image=#{image_1.id}]
        [source]https://zxc.org[/source]
      TEXT
    end

    it do
      is_expected.to have_attributes(
        text: "test[image=#{image_1.id}]",
        wall: nil,
        source: 'https://zxc.org'
      )
      expect(subject.wall_video).to be_nil
      expect(subject.wall_images).to be_empty
    end
  end

  context 'wall & source' do
    let(:body) do
      <<~TEXT.squish.strip
        test[image=#{image_1.id}]
        [wall]
        [video=#{video.id}]
        [image=#{image_2.id}]
        [image=#{image_3.id}]
        [/wall]
        [source]https://zxc.org[/source]
      TEXT
    end

    let(:image_2) { create :user_image }
    let(:image_3) { create :user_image }
    let(:video) { create :video }

    it do
      is_expected.to have_attributes(
        text: "test[image=#{image_1.id}]",
        wall: (
          <<~TEXT.squish.strip
            [wall]
            [video=#{video.id}]
            [image=#{image_2.id}]
            [image=#{image_3.id}]
            [/wall]
          TEXT
        ),
        source: 'https://zxc.org'
      )
      expect(subject.wall_video).to eq video
      expect(subject.wall_images).to eq [image_2, image_3]
    end
  end

  context 'wall & source & replies & bans' do
    let(:body) do
      <<~TEXT.squish.strip
        test[image=#{image_1.id}]
        [wall]
        [video=#{video.id}]
        [image=#{image_2.id}]
        [image=#{image_3.id}]
        [/wall]
        [source]https://zxc.org[/source]

        [replies=123,1234]
        [ban=1]
      TEXT
    end

    let(:image_2) { create :user_image }
    let(:image_3) { create :user_image }
    let(:video) { create :video }

    it do
      is_expected.to have_attributes(
        text: "test[image=#{image_1.id}] [replies=123,1234] [ban=1]",
        wall: (
          <<~TEXT.squish.strip
            [wall]
            [video=#{video.id}]
            [image=#{image_2.id}]
            [image=#{image_3.id}]
            [/wall]
          TEXT
        ),
        source: 'https://zxc.org'
      )
      expect(subject.wall_video).to eq video
      expect(subject.wall_images).to eq [image_2, image_3]
    end
  end
end
