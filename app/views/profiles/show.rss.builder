history_groups, = UserHistoryQuery.new(@resource).postload(1, 30)

xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title "#{@resource.nickname} / Шикимори"
    xml.description "Изменения списка #{@resource.nickname}"
    xml.link profile_url(@resource)

    history_groups.each do |_date, history_group|
      history_group.each do |history|
        xml.item do
          xml.title history.target ? history.target.name : history.action.capitalize

          if history.target
            html = "#{strip_tags history.format} \
<a href=\"#{url_for history.target}\">#{history.target.name}</a>"
            text = format_rss_urls html
            xml.description text
          else
            xml.description history.format
          end

          xml.pubDate Time.zone.at(history.created_at.to_i).to_fs(:rfc822)
        end
      end
    end
  end
end
