describe QueryObjectBase do
  subject(:query) { QueryObjectBase.new collection }
  let(:collection) { %i[zz xx] }

  it { is_expected.to eq collection }

  describe 'scope method' do
    subject { query.slice(1, 1) }
    it { is_expected.to eq collection[1, 1] }
  end

  describe '#paginate' do
    let(:collection) { User.all.order(:id) }

    subject { query.paginate 1, 1 }

    it { expect(subject.to_a).to eq User.all.order(:id).limit(1) }
    its(:page) { is_expected.to eq 1 }
  end

  describe 'query methods' do
    let(:collection) { User.where(id: [user.id, user_admin.id]).order(:id) }
    subject { query }

    it { is_expected.to eq [user_admin, user] }

    describe 'decoration method' do
      subject { query.paginate(2, 1) }

      it { is_expected.to eq [user] }
      its(:page) { is_expected.to eq 2 }
    end
  end
end
