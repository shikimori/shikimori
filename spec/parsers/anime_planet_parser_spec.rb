
require 'spec_helper'

describe AnimePlanetParser do
  let (:nickname) { 'morr507' }
  let (:nickname2) { 'morrr507' }

  [[Anime, 15, 713, {
      status: "Watching",
      score: 5.0,
      name: "Zombie-Loan Specials",
      episodes: 1
    }], [Manga, 1, 16, {
      status: "Want to Read",
      volumes: 0,
      chapters: 0,
      name: "Watashitachi no Shiawase na Jikan",
      score: 0.0
   }]].each do |klass, list_pages, list_count, last_element|
    describe klass do
      let(:parser) { AnimePlanetParser.new(nickname, klass) }

      it "get list pages" do
        parser.get_pages_num.should eq(list_pages)
      end

      it "get list elements" do
        parser.get_pages_num
        list = parser.get_list
        list.should have_at_least(list_count-1).items
        list.last.should eq(last_element)
      end
    end
  end

  it 'basic import' do
    parser = AnimePlanetParser.new(nickname, Anime)
    user = create :user

    list = [{
      status: "Watching",
      score: 5.0,
      name: "Zombie-Loan Specials",
      episodes: 1
    }, {
      status: "Watching",
      score: 5.0,
      name: "Zombie-Loan,.",
      episodes: 1
    }]
    create :anime, name: "Zombie-Loan"
    create :anime, name: "Zombie-Loan Specials"

    expect {
      parser.import_list(user, list, false, nil)
    }.to change(UserRate, :count).by list.size
  end

  describe 'real user import' do
    let(:parser) { AnimePlanetParser.new(nickname2, Anime) }
    let(:user) { create :user }

    def prepare_data
      parser.get_pages_num.should eq(1)
      list = parser.get_list
      list.should have(3).items
      list.each {|anime| create :anime, name: anime[:name] }
      list << {
        status: "Watching",
        score: 5.0,
        name: "Not matched anime",
        episodes: 1
      }
      list
    end

    it 'with rewrite and wont watch to dropped' do
      list = prepare_data

      added, updated, not_imported = 0, 0, 0
      expect {
        added, updated, not_imported = parser.import_list(user, list, true, UserRateStatus::Dropped)
      }.to change(UserRate, :count).by list.size - 1

      [added.size, updated.size, not_imported.size].should eq([3, 0, 1])

      user.anime_rates.select {|v| v.status == UserRateStatus.get(UserRateStatus::Dropped) }.should have(1).item
      user.anime_rates.select {|v| v.status == UserRateStatus.get(UserRateStatus::Completed) }.should have(1).item
      user.anime_rates.select {|v| v.status == UserRateStatus.get(UserRateStatus::Watching) }.should have(1).item
    end

    it 'wont watch shouldnt increment not imported counter' do
      list = prepare_data

      added, updated, not_imported = 0, 0, 0
      expect {
        added, updated, not_imported = parser.import_list(user, list, true, nil)
      }.to change(UserRate, :count).by(list.size - 2)

      [added.size, updated.size, not_imported.size].should eq([2, 0, 1])
    end

    it 'ignores twice matched' do
      create :anime, name: "Zombie-Loan"
      list = [{
        status: "Watching",
        score: 5.0,
        name: "Zombie-Loan",
        episodes: 1
      }, {
        status: "Watching",
        score: 5.0,
        name: "Zombie-Loan",
        episodes: 1
      }]

      added, updated, not_imported = 0, 0, 0
      added, updated, not_imported = parser.import_list(user, list, true, nil)

      [added.size, updated.size, not_imported.size].should eq([0, 0, 2])
    end
  end

  describe 'status conversion' do
    let (:parser) { AnimePlanetParser.new(nickname, Anime) }

    it 'Watched/Read' do
      parser.instance_eval { convert_status("Watched") }.should == UserRateStatus::Completed
      parser.instance_eval { convert_status("Read") }.should == UserRateStatus::Completed
    end

    it 'Watching/Reading' do
      parser.instance_eval { convert_status("Watching") }.should == UserRateStatus::Watching
      parser.instance_eval { convert_status("Reading") }.should == UserRateStatus::Watching
    end

    it 'Want to Watch/Want to Read' do
      parser.instance_eval { convert_status("Want to Watch") }.should == UserRateStatus::Planned
      parser.instance_eval { convert_status("Want to Read") }.should == UserRateStatus::Planned
    end

    it 'Stalled' do
      parser.instance_eval { convert_status("Stalled") }.should == UserRateStatus::OnHold
    end

    it 'Dropped' do
      parser.instance_eval { convert_status("Dropped") }.should == UserRateStatus::Dropped
    end

    it 'Wont Watch/Wont Read' do
      parser.instance_eval { convert_status("Won't Watch") }.should be_nil
      parser.instance_eval { convert_status("Won't Read") }.should be_nil
      parser.instance_eval { convert_status("Won't Watch", UserRateStatus::Dropped) }.should == UserRateStatus::Dropped
      parser.instance_eval { convert_status("Won't Read", UserRateStatus::Dropped) }.should == UserRateStatus::Dropped
    end
  end
end
