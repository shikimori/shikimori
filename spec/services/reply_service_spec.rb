describe ReplyService do
  let(:service) { ReplyService.new comment }
  let(:comment) { create :comment, body: body }
  let(:replied_comment) { create :comment }

  describe '#append_reply' do
    before { allow(service.send :faye).to receive :set_replies }
    before { service.append_reply replied_comment }

    context 'no replies' do
      let(:body) { 'test' }
      it { expect(comment.body).to eq "test\n\n[replies=#{replied_comment.id}]" }
    end

    context 'has the same reply' do
      let(:body) { "test\n[replies=#{replied_comment.id}]" }
      it { expect(comment.body).to eq body }
    end

    context 'has another reply' do
      let(:body) { "test\n[replies=987654321]" }
      it { expect(comment.body).to eq "test\n[replies=#{replied_comment.id},987654321]" }
    end

    describe 'faye' do
      let(:body) { 'test' }
      it { expect(service.send :faye).to have_received(:set_replies).with comment }
    end
  end

  describe '#remove_reply' do
    before { allow(service.send :faye).to receive :set_replies }
    before { service.remove_reply replied_comment }

    let(:comment) { create :comment, body: body }

    context 'has one reply' do
      let(:body) { "test\n[replies=#{replied_comment.id}]" }
      it { expect(comment.body).to eq "test" }
    end

    context 'has multiple replies' do
      let(:body) { "test\n[replies=#{replied_comment.id},987654321]" }
      it { expect(comment.body).to eq "test\n[replies=987654321]" }
    end

    describe 'faye' do

      context 'no reply' do
        let(:body) { 'test' }
        it { expect(service.send :faye).to_not have_received :set_replies }
      end

      context 'has reply' do
        let(:body) { "test\n[replies=#{replied_comment.id}]" }
        it { expect(service.send :faye).to have_received(:set_replies).with comment }
      end
    end
  end
end
