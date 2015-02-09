xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title "#{@user.nickname} / Шикимори"
    xml.description "Изменения списка #{@user.nickname}"
    xml.link profile_url(@user)

    @history.each do |h_entry|
      xml.item do
        xml.title h_entry.target ? h_entry.target.name : h_entry.action.capitalize
        if h_entry.target
          text = "#{strip_tags h_entry.format} <a href='#{format_rss_urls(url_for h_entry.target)}'>#{h_entry.target.name}</a>"
          xml.description text
        else
          xml.description h_entry.format
        end
        xml.pubDate Time.at(h_entry.created_at.to_i).to_s(:rfc822)
      end
    end
  end
end
