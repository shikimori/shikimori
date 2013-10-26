xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{@user.nickname} / Шикимори"
    xml.description "Изменения списка #{@user.nickname}"
    xml.link user_url(@user)

    (@history || []).each do |h_entry|
      xml.item do
        xml.title h_entry.target ? h_entry.target.name : h_entry.action.capitalize
        xml.description format_rss_urls(format_user_history(h_entry, false, false, true))
        xml.pubDate Time.at(h_entry.created_at.to_i).to_s(:rfc822)
        #xml.link url_for(h_entry.target).sub(/^\//, 'http://shikimori.org/') if h_entry.target
      end
    end
  end
end
