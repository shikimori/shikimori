module ForumsHelper
  def build_forum_url
    section_url(:id => '4-site', :only_path => false)
  end
end
