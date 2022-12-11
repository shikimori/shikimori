class Moderations::ChangelogsController < ModerationsController
  def index
    og page_title: i18n_t('page_title')
    @collection = `ls #{Rails.root.join 'log'} | grep changelog`
      .strip
      .split("\n")
      .map { |v| v.gsub(/changelog_|\.log/, '') }
  end

  def show # rubocop:disable all
    og page_title: params[:id]
    breadcrumb i18n_t('page_title'), moderations_changelogs_url

    log_name = Shellwords.shellescape(params[:id]).gsub(/[^\w_]/, '')
    log_file = Rails.root.join "log/changelog_#{log_name}.log"

    command =
      if params[:search].present?
        "grep \"#{Shellwords.shellescape params[:search]}\" #{log_file} | tail -n 250"
      else
        "tail -n 10 #{log_file}"
      end

    @collection = `#{command}`.strip.each_line.map(&:strip).map do |log_entry|
      split = log_entry.split(/(?<=\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}\]) /)
      changes = split[1]
        .gsub(/ ?:([a-z_]+)=>/, '"\1":')
        .gsub(/"([a-z_]+)"=>/, '"\1":')
        .gsub(/"action"::(update|destroy)/, '"action":"\1"')
        .gsub(/(?<=":)#<\w+(?<model>[\s\S]+)>(?=}\Z)/) do
          '{' +
            $LAST_MATCH_INFO[:model]
              .gsub(/ ([a-z_]+): /, '"\1":')
              .gsub(':nil', ':null') +
            '}'
        end
      json = JSON.parse(changes, symbolize_names: true)
      if json[:model].is_a? String
        json[:model] = JSON.parse(json[:model], symbolize_names: true)
      end

      {
        date: Time.zone.parse(split[0].gsub(/[\[\]]/, '')),
        log: json,
        raw: log_entry
      }
    end
  end
end
