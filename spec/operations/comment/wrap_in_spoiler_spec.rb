describe Comment::WrapInSpoiler do
  let!(:comment1) { create :comment, :skip_forbid_tags_change, body: comment_body1, user: user }
  let!(:comment2) { create :comment, :skip_forbid_tags_change, body: comment_body2, user: user }
  let!(:comment3) { create :comment, :skip_forbid_tags_change, body: comment_body3, user: user }
  let!(:comment4) { create :comment, :skip_forbid_tags_change, body: comment_body4, user: user }

  let(:comment_body1) do
    'хоро любит яблоки'
  end

  let(:comment_body2) do
    'хоро не мяукает потому что она волкодевушка\n\n[replies=73691156,736156]'
  end

  let(:comment_body3) do
    '[comment=1974;206], мяу это способ выявлять унылых собеседников\n\n[ban=40518]'
  end

  let(:comment_body4) do
    'коната изуми\n\n[ban=40505]\n\n[replies=7369154,7369155]'
  end

  context 'wrap in spoiler simple text' do
    it do
      Comment::WrapInSpoiler.call(comment1)
      expect(comment1.body).to eq "[spoiler=Скрыто модератором]#{comment_body1}[/spoiler]"
    end
  end

  context 'wrap in spoiler text with replies' do
    it do
      Comment::WrapInSpoiler.call(comment2)
      expect(comment2.body).to eq "[spoiler=Скрыто модератором]хоро не мяукает потому что она волкодевушка[/spoiler]\n\n[replies=73691156,736156]"
    end
  end

  context 'wrap in spoiler text with bans' do
    it do
      Comment::WrapInSpoiler.call(comment3)
      expect(comment3.body).to eq "[spoiler=Скрыто модератором][comment=1974;206], мяу это способ выявлять унылых собеседников[/spoiler]\n\n[ban=40518]"
    end
  end

  context 'wrap in spoiler text with replies and bans' do
    it do
      Comment::WrapInSpoiler.call(comment4)
      expect(comment4.body).to eq "[spoiler=Скрыто модератором]коната изуми[/spoiler]\n\n[ban=40505]\n\n[replies=7369154,7369155]"
    end
  end

end
