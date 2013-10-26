class ConvertHistoryAndMessages < ActiveRecord::Migration
  def self.up
    ap AnimeHistory.connection().update_sql("update anime_histories set action='%s' where action='new_anons'" % AnimeHistoryAction::Anons)
    ap AnimeHistory.connection().update_sql("update anime_histories set action='%s' where action='new_ongoing'" % AnimeHistoryAction::Ongoing)
    ap AnimeHistory.connection().update_sql("update anime_histories set action='%s' where action='new_episode'" % AnimeHistoryAction::Episode)
    ap AnimeHistory.connection().update_sql("update anime_histories set action='%s' where action='anime_released'" % AnimeHistoryAction::Release)

    ap Message.connection().update_sql("update messages set message_type='%s' where message_type='new_anons'" % AnimeHistoryAction::Anons)
    ap Message.connection().update_sql("update messages set message_type='%s' where message_type='new_ongoing'" % AnimeHistoryAction::Ongoing)
    ap Message.connection().update_sql("update messages set message_type='%s' where message_type='new_episode'" % AnimeHistoryAction::Episode)
    ap Message.connection().update_sql("update messages set message_type='%s' where message_type='anime_released'" % AnimeHistoryAction::Release)
  end

  def self.down
    ap AnimeHistory.connection().update_sql("update anime_histories set action='new_anons' where action='%s'" % AnimeHistoryAction::Anons)
    ap AnimeHistory.connection().update_sql("update anime_histories set action='new_ongoing' where action='%s'" % AnimeHistoryAction::Ongoing)
    ap AnimeHistory.connection().update_sql("update anime_histories set action='new_episode' where action='%s'" % AnimeHistoryAction::Episode)
    ap AnimeHistory.connection().update_sql("update anime_histories set action='anime_released' where action='%s'" % AnimeHistoryAction::Release)

    ap Message.connection().update_sql("update messages set message_type='new_anons' where message_type='%s'" % AnimeHistoryAction::Anons)
    ap Message.connection().update_sql("update messages set message_type='new_ongoing' where message_type='%s'" % AnimeHistoryAction::Ongoing)
    ap Message.connection().update_sql("update messages set message_type='new_episode' where message_type='%s'" % AnimeHistoryAction::Episode)
    ap Message.connection().update_sql("update messages set message_type='anime_released' where message_type='%s'" % AnimeHistoryAction::Release)
  end
end
