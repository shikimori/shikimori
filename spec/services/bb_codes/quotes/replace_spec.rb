describe BbCodes::Quotes::Replace do
  subject do
    described_class.call(
      text: text,
      from_reply: from_reply,
      to_reply: to_reply
    )
  end
  let(:from_reply) { build_stubbed :comment, id: 99999 }
  let(:to_reply) { build_stubbed :topic, id: 88888 }

  [
    # invalid replacements
    [
      '[quote=99999]',
      '[quote=99999]'
    ],
    [
      '[quote=100000;11111;test]',
      '[quote=100000;11111;test]'
    ],
    [
      '[comment=100000]',
      '[comment=100000]'
    ],
    [
      '>?c100000;11111;test',
      '>?c100000;11111;test'
    ],

    # valid replacements
    [
      '[quote=99999;11111;test]',
      '[quote=t88888;11111;test]'
    ],
    [
      '[quote=c99999;11111;test]',
      '[quote=t88888;11111;test]'
    ],
    [
      '[comment=99999]',
      '[topic=88888]'
    ],
    [
      '[comment=99999;1',
      '[topic=88888;1'
    ],
    [
      '>?c99999;11111;test',
      '>?t88888;11111;test'
    ]
  ].each do |(original_text, replaced_text)|
    context "\"#{original_text}\" => \"#{replaced_text}\"" do
      let(:text) { original_text }
      it { is_expected.to eq replaced_text }
    end
  end
end
