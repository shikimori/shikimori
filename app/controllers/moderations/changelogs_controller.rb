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

    @collection = `tail -n 10 #{log_file}`.strip.each_line.map(&:strip).map do |log_entry|
      split = log_entry.split(/(?<=\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}\]) /)
      changes = split[1]
        .gsub(/ ?:([\w_]+)=>/, '"\1":')
        .gsub(/"([\w_]+)"=>/, '"\1":')
        .gsub(/"action"::(update|destroy)/, '"action":"\1"')
      log = JSON.parse(changes, symbolize_names: true)

      {
        date: Time.zone.parse(split[0].gsub(/[\[\]]/, '')),
        log: log,
        raw: log_entry
      }
    end
  end
end
