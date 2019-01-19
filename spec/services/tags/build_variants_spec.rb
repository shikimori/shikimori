describe Tags::BuildVariants do
  subject { described_class.call tags }

  context do
    let(:tags) do
      [
        'bo_bo',
        'sword art online',
        'sword_art_online',
        'Sword Art Online'
      ]
    end

    it do
      is_expected.to eq(
        'bo bo' => [
          'bo_bo'
        ],
        'sword art online' => [
          'sword art online',
          'sword_art_online',
          'Sword Art Online'
        ]
      )
    end
  end
end
