describe Forums::Form do
  include_context :view_context_stub

  let(:view) { Forums::Form.new }

  describe '#news_rules_topic' do
    let!(:rules_topic) { create :topic, id: Forums::Form::RULES_TOPIC_ID, body: rules_text }
    let(:rules_text) { "t[b]es[/b]t\n[hr]\ntest" }

    it { expect(view.news_rules_topic).to eq rules_topic }
    it { expect(view.news_rules_text).to eq 't<strong>es</strong>t' }
  end
end
