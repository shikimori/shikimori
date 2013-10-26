class SakuhindbJob < Struct.new(:with_fail)
  def perform
    parser = SakuhindbParser.new
    parser.fail_on_unmatched = with_fail
    parser.fetch_and_merge
  end
end
