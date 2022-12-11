class Moderations::ChangelogsController < ModerationsController
  LIMIT = 100
  TAIL_COMMAND = "tail -n #{LIMIT}"

  before_action :check_access!

  def index
    og page_title: i18n_t('page_title')
    @collection = `ls #{Rails.root.join 'log'} | grep changelog`
      .strip
      .split("\n")
      .map { |v| v.gsub(/changelog_|\.log/, '') }
  end

  def show # rubocop:disable all
    @item_type = params[:id].classify
    og page_title: @item_type
    breadcrumb i18n_t('page_title'), moderations_changelogs_url

    log_name = Shellwords.shellescape(params[:id]).gsub(/[^\w_]/, '')
    log_file = Rails.root.join "log/changelog_#{log_name}.log"

    command =
      if params[:search].present?
        "grep \"#{Shellwords.shellescape params[:search]}\" #{log_file} | #{TAIL_COMMAND}"
      else
        "#{TAIL_COMMAND} #{log_file}"
      end

    @users = {}
    @collection = `#{command}`.strip.each_line.map(&:strip).reverse.map do |log_entry|
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
      details = JSON.parse(changes, symbolize_names: true)
      if details[:model].is_a? String
        details[:model] = JSON.parse(details[:model], symbolize_names: true)
      end

      {
        date: Time.zone.parse(split[0].gsub(/[\[\]]/, '')),
        user_id: details[:user_id],
        details: details,
        raw: log_entry
      }
    end

    @users = User
      .where(id: @collection.pluck(:user_id))
      .index_by(&:id)
  end

private

  def check_access!
    authorize! :access_changelog, ApplicationRecord
  end
end
