describe Comment::WrapInSpoiler do
  subject! { described_class.call comment }

  let(:comment) do
    create :comment, :skip_forbid_tags_change,
      body: body,
      user: user
  end
  let(:sample) { 'хоро любит яблоки' }
  let(:prefix) { described_class::SPOILER_START }
  let(:suffix) { described_class::SPOILER_END }

  context 'common text' do
    let(:body) { sample }

    it do
      expect(comment).to_not be_changed
      expect(comment.body).to eq "#{prefix}#{sample}#{suffix}"
    end
  end

  context 'with replies' do
    let(:body) { "#{sample}\n\n[replies=73691156,736156]" }

    it do
      expect(comment.body).to eq(
        "#{prefix}#{sample}#{suffix}\n\n[replies=73691156,736156]"
      )
    end
  end

  context 'with bans' do
    let(:body) { "#{sample}\n\n[ban=40518]" }

    it do
      expect(comment.body).to eq(
        "#{prefix}#{sample}#{suffix}\n\n[ban=40518]"
      )
    end
  end

  context 'all together' do
    let(:body) do
      "#{sample}\n\n[ban=40505]\n\n[replies=7369154,7369155]"
    end

    it do
      expect(comment.body).to eq(
        "#{prefix}#{sample}#{suffix}\n\n[ban=40505]\n\n[replies=7369154,7369155]"
      )
    end
  end
end
