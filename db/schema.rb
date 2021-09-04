# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_04_100350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "abuse_requests", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "comment_id", null: false
    t.string "kind", limit: 255
    t.boolean "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state", limit: 255
    t.integer "approver_id"
    t.string "reason", limit: 4096
    t.index ["comment_id", "kind", "value"], name: "index_abuse_requests_on_comment_id_and_kind_and_value", unique: true, where: "((state)::text = 'pending'::text)"
  end

  create_table "achievements", id: :serial, force: :cascade do |t|
    t.string "neko_id", null: false
    t.integer "level", null: false
    t.integer "progress", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["neko_id", "level"], name: "index_achievements_on_neko_id_and_level"
    t.index ["user_id", "neko_id", "level"], name: "index_achievements_on_user_id_and_neko_id_and_level", unique: true
  end

  create_table "anime_calendars", id: :serial, force: :cascade do |t|
    t.integer "anime_id"
    t.integer "episode"
    t.datetime "start_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["anime_id", "episode"], name: "index_anime_calendars_on_anime_id_and_episode", unique: true
  end

  create_table "anime_links", id: :serial, force: :cascade do |t|
    t.integer "anime_id"
    t.string "service", limit: 255, null: false
    t.string "identifier", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anime_id", "service", "identifier"], name: "index_anime_links_on_anime_id_and_service_and_identifier", unique: true
  end

  create_table "anime_stat_histories", force: :cascade do |t|
    t.jsonb "scores_stats", default: [], null: false
    t.jsonb "list_stats", default: [], null: false
    t.string "entry_type", null: false
    t.bigint "entry_id", null: false
    t.date "created_on", null: false
    t.index ["entry_id", "entry_type", "created_on"], name: "index_anime_stat_histories_on_e_id_and_e_type_and_created_on", unique: true
    t.index ["entry_type", "entry_id"], name: "index_anime_stat_histories_on_entry_type_and_entry_id"
  end

  create_table "anime_stats", force: :cascade do |t|
    t.jsonb "scores_stats", default: [], null: false
    t.jsonb "list_stats", default: [], null: false
    t.string "entry_type", null: false
    t.bigint "entry_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_type", "entry_id"], name: "index_anime_stats_on_entry_type_and_entry_id", unique: true
  end

  create_table "anime_video_authors", id: :serial, force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_verified", default: false, null: false
  end

  create_table "anime_video_reports", id: :serial, force: :cascade do |t|
    t.integer "anime_video_id"
    t.integer "user_id"
    t.integer "approver_id"
    t.string "kind", limit: 255
    t.string "state", limit: 255
    t.string "user_agent", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message", limit: 1000
    t.index ["user_id", "state"], name: "index_anime_video_reports_on_user_id_and_state"
  end

  create_table "anime_videos", id: :serial, force: :cascade do |t|
    t.integer "anime_id"
    t.string "url", limit: 1000
    t.string "source", limit: 1000
    t.integer "episode"
    t.string "kind", limit: 255
    t.string "language", limit: 255
    t.integer "anime_video_author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state", limit: 255, default: "working", null: false
    t.integer "watch_view_count"
    t.string "quality"
    t.boolean "is_first", default: false, null: false
    t.index ["anime_id", "state"], name: "index_anime_videos_on_anime_id_and_state"
    t.index ["anime_video_author_id"], name: "index_anime_videos_on_anime_video_author_id"
  end

  create_table "animes", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "description_ru", limit: 16384
    t.string "description_en", limit: 16384
    t.string "kind", limit: 255
    t.integer "episodes", default: 0, null: false
    t.integer "duration"
    t.decimal "score", default: "0.0", null: false
    t.integer "ranked"
    t.integer "popularity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "image_file_name", limit: 255
    t.string "image_content_type", limit: 255
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.date "aired_on"
    t.date "released_on"
    t.string "status", limit: 255
    t.string "rating", limit: 255
    t.integer "episodes_aired", default: 0, null: false
    t.string "russian", limit: 255, default: "", null: false
    t.boolean "is_censored", default: false
    t.datetime "imported_at"
    t.datetime "next_episode_at"
    t.string "imageboard_tag", limit: 255
    t.string "torrents_name", limit: 255
    t.float "site_score", default: 0.0, null: false
    t.text "desynced", default: [], null: false, array: true
    t.string "origin"
    t.string "broadcast"
    t.string "english", limit: 255
    t.string "japanese", limit: 255
    t.integer "mal_id"
    t.datetime "authorized_imported_at"
    t.text "synonyms", default: [], null: false, array: true
    t.integer "cached_rates_count", default: 0, null: false
    t.integer "genre_ids", default: [], null: false, array: true
    t.integer "studio_ids", default: [], null: false, array: true
    t.string "season", limit: 255
    t.string "franchise", limit: 255
    t.string "license_name_ru"
    t.text "coub_tags", default: [], null: false, array: true
    t.text "fansubbers", default: [], null: false, array: true
    t.text "fandubbers", default: [], null: false, array: true
    t.string "options", default: [], null: false, array: true
    t.string "licensors", default: [], null: false, array: true
    t.index ["kind"], name: "index_animes_on_kind"
    t.index ["name"], name: "index_animes_on_name"
    t.index ["rating"], name: "index_animes_on_rating"
    t.index ["russian"], name: "index_animes_on_russian"
    t.index ["score"], name: "index_animes_on_score"
    t.index ["status", "score", "kind"], name: "anime_online_dashboard_query"
  end

  create_table "articles", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.bigint "user_id", null: false
    t.string "body", limit: 140000, null: false
    t.string "moderation_state", limit: 255, default: "pending"
    t.integer "approver_id"
    t.text "tags", default: [], null: false, array: true
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state", null: false
    t.datetime "changed_at"
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "bans", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "comment_id"
    t.integer "abuse_request_id"
    t.integer "moderator_id"
    t.integer "duration", null: false
    t.string "reason", limit: 4096
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bans_on_user_id"
  end

  create_table "characters", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "japanese", limit: 255
    t.string "fullname", limit: 255
    t.string "description_ru", limit: 32768
    t.string "description_en", limit: 32768
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "image_file_name", limit: 255
    t.string "image_content_type", limit: 255
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "imported_at"
    t.string "imageboard_tag", limit: 255
    t.string "russian", default: "", null: false
    t.text "desynced", default: [], null: false, array: true
    t.integer "mal_id"
    t.boolean "is_anime", default: false, null: false
    t.boolean "is_manga", default: false, null: false
    t.boolean "is_ranobe", default: false, null: false
    t.index ["name"], name: "index_characters_on_name"
    t.index ["russian"], name: "index_characters_on_russian"
  end

  create_table "club_bans", id: :serial, force: :cascade do |t|
    t.integer "club_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["club_id", "user_id"], name: "index_club_bans_on_club_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_club_bans_on_user_id"
  end

  create_table "club_images", id: :serial, force: :cascade do |t|
    t.integer "club_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "image_file_name", limit: 255
    t.string "image_content_type", limit: 255
    t.integer "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "club_invites", id: :serial, force: :cascade do |t|
    t.integer "club_id"
    t.integer "src_id"
    t.integer "dst_id"
    t.string "status", limit: 255, default: "Pending"
    t.integer "message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["club_id", "dst_id", "status"], name: "uniq_group_invites", unique: true
  end

  create_table "club_links", id: :serial, force: :cascade do |t|
    t.integer "club_id"
    t.integer "linked_id"
    t.string "linked_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["club_id", "linked_id", "linked_type"], name: "index_club_links_on_club_id_and_linked_id_and_linked_type", unique: true
  end

  create_table "club_pages", id: :serial, force: :cascade do |t|
    t.integer "club_id", null: false
    t.integer "parent_page_id"
    t.string "name", limit: 255, null: false
    t.string "text", limit: 500000, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", null: false
    t.string "layout", default: "---\n:default: :content\n", null: false
    t.index ["club_id"], name: "index_club_pages_on_club_id"
  end

  create_table "club_roles", id: :serial, force: :cascade do |t|
    t.string "role", limit: 255, default: "member"
    t.integer "user_id"
    t.integer "club_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "club_id"], name: "uniq_user_in_group", unique: true
  end

  create_table "clubs", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "description", limit: 600000
    t.string "logo_file_name", limit: 255
    t.string "logo_content_type", limit: 255
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer "club_roles_count", default: 0
    t.boolean "display_images", default: true
    t.boolean "is_censored", default: false, null: false
    t.string "locale", null: false
    t.integer "style_id"
    t.string "image_upload_policy", null: false
    t.string "join_policy", null: false
    t.string "comment_policy", null: false
    t.string "topic_policy", null: false
  end

  create_table "collection_links", id: :serial, force: :cascade do |t|
    t.integer "collection_id", null: false
    t.string "linked_type", null: false
    t.integer "linked_id", null: false
    t.string "group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "text", limit: 2048
    t.index ["collection_id", "linked_id", "group"], name: "uniq_collections_linked_links", unique: true
    t.index ["linked_type", "linked_id"], name: "index_collection_links_on_linked_type_and_linked_id"
  end

  create_table "collection_roles", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_collection_roles_on_collection_id"
    t.index ["user_id", "collection_id"], name: "index_collection_roles_on_user_id_and_collection_id", unique: true
  end

  create_table "collections", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.integer "user_id", null: false
    t.string "kind", null: false
    t.string "text", limit: 400000, null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state", null: false
    t.string "moderation_state", limit: 255, default: "pending"
    t.integer "approver_id"
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.datetime "published_at"
    t.datetime "changed_at"
    t.text "tags", default: [], null: false, array: true
    t.integer "links_count", default: 0, null: false
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "comment_viewings", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "viewed_id", null: false
    t.index ["user_id", "viewed_id"], name: "index_comment_viewings_on_user_id_and_viewed_id", unique: true
    t.index ["viewed_id"], name: "index_comment_viewings_on_viewed_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type", limit: 15
    t.string "body", limit: 64000
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_summary", default: false, null: false
    t.boolean "is_offtopic", default: false, null: false
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["created_at"], name: "index_comments_on_created_at"
    t.index ["user_id", "id"], name: "index_comments_on_user_id_and_id"
  end

  create_table "contest_links", id: :serial, force: :cascade do |t|
    t.integer "contest_id"
    t.integer "linked_id"
    t.string "linked_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["linked_id", "linked_type", "contest_id"], name: "index_contest_links_on_linked_id_and_linked_type_and_contest_id"
  end

  create_table "contest_matches", id: :serial, force: :cascade do |t|
    t.integer "round_id"
    t.string "state", limit: 255, default: "created"
    t.string "group", limit: 255
    t.integer "left_id"
    t.string "left_type", limit: 255
    t.integer "right_id"
    t.string "right_type", limit: 255
    t.date "started_on"
    t.date "finished_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "winner_id"
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.integer "cached_votes_total", default: 0
    t.index ["round_id"], name: "index_contest_votes_on_contest_round_id"
  end

  create_table "contest_rounds", id: :serial, force: :cascade do |t|
    t.integer "contest_id"
    t.string "state", limit: 255, default: "created"
    t.integer "number"
    t.boolean "additional"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["contest_id"], name: "index_contest_rounds_on_contest_id"
  end

  create_table "contest_suggestions", id: :serial, force: :cascade do |t|
    t.integer "contest_id"
    t.integer "user_id"
    t.integer "item_id"
    t.string "item_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_contest_suggestions_on_contest_id"
    t.index ["user_id"], name: "index_contest_suggestions_on_user_id"
  end

  create_table "contest_winners", id: :serial, force: :cascade do |t|
    t.integer "contest_id", null: false
    t.integer "position", null: false
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_contest_winners_on_contest_id"
    t.index ["item_type", "item_id"], name: "index_contest_winners_on_item_type_and_item_id"
  end

  create_table "contests", id: :serial, force: :cascade do |t|
    t.string "title_ru", limit: 255
    t.integer "user_id"
    t.string "state", limit: 255, default: "created"
    t.date "started_on"
    t.integer "matches_per_round"
    t.integer "match_duration"
    t.integer "matches_interval"
    t.integer "wave_days"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "finished_on"
    t.string "user_vote_key", limit: 255
    t.string "strategy_type", limit: 255, default: "Contest::DoubleEliminationStrategy", null: false
    t.integer "suggestions_per_user"
    t.string "member_type", limit: 255, default: "anime"
    t.string "title_en", limit: 255
    t.integer "cached_uniq_voters_count", default: 0, null: false
    t.string "description_ru", limit: 32768
    t.string "description_en", limit: 32768
    t.index ["state", "started_on", "finished_on"], name: "index_contests_on_state_and_started_on_and_finished_on"
  end

  create_table "cosplay_galleries", id: :serial, force: :cascade do |t|
    t.string "cos_rain_id", limit: 255
    t.string "target", limit: 255
    t.string "description_cos_rain", limit: 16384
    t.string "description", limit: 16384
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "confirmed", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.string "source", limit: 255
    t.integer "user_id"
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.index ["cos_rain_id"], name: "index_cosplay_galleries_on_cos_rain_id", unique: true
  end

  create_table "cosplay_gallery_links", id: :serial, force: :cascade do |t|
    t.integer "linked_id"
    t.string "linked_type", limit: 255
    t.integer "cosplay_gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cosplay_gallery_id", "linked_type"], name: "i_cosplay_gallery_id_linked_type"
    t.index ["linked_id", "linked_type", "cosplay_gallery_id"], name: "index_cosplay_gallery_links_on_l_id_and_l_type_and_cg_id", unique: true
  end

  create_table "cosplay_images", id: :serial, force: :cascade do |t|
    t.integer "cosplay_gallery_id"
    t.string "url", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "image_file_name", limit: 255
    t.string "image_content_type", limit: 255
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.boolean "deleted", default: false, null: false
    t.integer "position"
    t.index ["cosplay_gallery_id", "deleted"], name: "i_cosplay_images_gallery_id_deleted"
  end

  create_table "cosplayers", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "website", limit: 255
    t.string "image_url", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_cosplayers_on_name", unique: true
  end

  create_table "coub_tags", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_coub_tags_on_name", unique: true
  end

  create_table "danbooru_tags", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "ambiguous"
  end

  create_table "episode_notifications", id: :serial, force: :cascade do |t|
    t.integer "anime_id", null: false
    t.integer "episode", null: false
    t.boolean "is_raw", default: false, null: false
    t.boolean "is_subtitles", default: false, null: false
    t.boolean "is_fandub", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_anime365", default: false, null: false
    t.index ["anime_id", "episode"], name: "index_episode_notifications_on_anime_id_and_episode", unique: true
  end

  create_table "external_links", id: :serial, force: :cascade do |t|
    t.integer "entry_id", null: false
    t.string "entry_type", null: false
    t.string "kind", null: false
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "imported_at"
    t.string "source", null: false
    t.string "checksum", null: false
    t.index ["checksum"], name: "index_external_links_on_checksum", unique: true, where: "((url)::text <> 'NONE'::text)"
    t.index ["entry_type", "entry_id"], name: "index_external_links_on_entry_type_and_entry_id"
  end

  create_table "favourites", id: :serial, force: :cascade do |t|
    t.integer "linked_id", null: false
    t.string "linked_type", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kind", default: "", null: false
    t.integer "position", null: false
    t.index ["linked_id", "linked_type", "kind", "user_id"], name: "favorites_linked_id_linked_type_kind_user_id", unique: true, where: "(kind IS NOT NULL)"
    t.index ["linked_id", "linked_type", "user_id"], name: "favorites_linked_id_linked_type_user_id", unique: true, where: "(kind IS NULL)"
    t.index ["linked_type", "linked_id"], name: "i_linked"
    t.index ["user_id"], name: "index_favourites_on_user_id"
  end

  create_table "forums", id: :serial, force: :cascade do |t|
    t.integer "position", null: false
    t.string "name_ru", null: false
    t.string "permalink", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_en", null: false
  end

  create_table "friend_links", id: :serial, force: :cascade do |t|
    t.integer "src_id"
    t.integer "dst_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["src_id", "dst_id"], name: "index_friend_links_on_src_id_and_dst_id", unique: true
  end

  create_table "genres", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "russian", limit: 255
    t.integer "position"
    t.integer "seo", default: 99
    t.string "description", limit: 4096
    t.string "kind", null: false
    t.integer "mal_id", null: false
    t.index ["mal_id", "kind"], name: "index_genres_on_mal_id_and_kind", unique: true
  end

  create_table "ignores", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "target_id"], name: "index_ignores_on_user_id_and_target_id", unique: true
  end

  create_table "list_imports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "list_file_name", null: false
    t.string "list_content_type"
    t.integer "list_file_size"
    t.datetime "list_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state", null: false
    t.string "duplicate_policy", null: false
    t.string "list_type", null: false
    t.jsonb "output"
    t.boolean "is_archived", default: false, null: false
    t.index ["user_id"], name: "index_list_imports_on_user_id"
  end

  create_table "mangas", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "description_ru", limit: 16384
    t.string "description_en", limit: 16384
    t.string "kind", limit: 255
    t.integer "volumes", default: 0, null: false
    t.integer "volumes_aired", default: 0, null: false
    t.integer "chapters", default: 0, null: false
    t.integer "chapters_aired", default: 0, null: false
    t.string "status", limit: 255
    t.string "russian", limit: 255, default: "", null: false
    t.decimal "score", default: "0.0", null: false
    t.integer "ranked"
    t.integer "popularity"
    t.string "rating", limit: 255
    t.date "aired_on"
    t.date "released_on"
    t.datetime "imported_at"
    t.string "image_file_name", limit: 255
    t.string "image_content_type", limit: 255
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.boolean "is_censored", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "imageboard_tag", limit: 255
    t.float "site_score", default: 0.0, null: false
    t.datetime "parsed_at"
    t.text "desynced", default: [], null: false, array: true
    t.string "english", limit: 255
    t.string "japanese", limit: 255
    t.integer "mal_id"
    t.string "type"
    t.datetime "authorized_imported_at"
    t.text "synonyms", default: [], null: false, array: true
    t.integer "cached_rates_count", default: 0, null: false
    t.integer "genre_ids", default: [], null: false, array: true
    t.integer "publisher_ids", default: [], null: false, array: true
    t.string "franchise", limit: 255
    t.string "license_name_ru"
    t.string "licensors", default: [], null: false, array: true
    t.index ["kind"], name: "index_mangas_on_kind"
    t.index ["name"], name: "index_mangas_on_name"
    t.index ["russian"], name: "index_mangas_on_russian"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.integer "from_id"
    t.integer "to_id"
    t.string "kind", limit: 255
    t.string "body", limit: 900000
    t.boolean "read", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted_by_to", default: false
    t.boolean "emailed", default: false
    t.integer "linked_id", default: 0, null: false
    t.string "linked_type", limit: 255
    t.index ["from_id", "id"], name: "index_messages_on_from_id_and_id"
    t.index ["from_id", "kind"], name: "private_and_notifications"
    t.index ["linked_type", "linked_id"], name: "index_messages_on_linked_type_and_linked_id"
    t.index ["to_id", "kind", "read"], name: "messages_for_profile"
    t.index ["to_id", "linked_id"], name: "index_messages_on_to_id_and_linked_id"
  end

  create_table "name_matches", id: :serial, force: :cascade do |t|
    t.string "phrase", null: false
    t.integer "priority", null: false
    t.integer "group", null: false
    t.integer "target_id", null: false
    t.string "target_type", null: false
    t.index ["phrase"], name: "index_name_matches_on_phrase"
    t.index ["target_type", "target_id"], name: "index_name_matches_on_target_type_and_target_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id", "application_id"], name: "index_oauth_access_tokens_on_resource_owner_id_and_app_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner_id"
    t.string "owner_type"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.string "description_ru", limit: 16384, null: false
    t.string "description_en", limit: 16384, null: false
    t.boolean "confidential", default: true, null: false
    t.string "allowed_scopes", default: [], null: false, array: true
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "japanese", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "image_file_name", limit: 255
    t.string "image_content_type", limit: 255
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.date "birthday"
    t.string "website", limit: 255
    t.datetime "imported_at"
    t.boolean "producer", default: false
    t.boolean "mangaka", default: false
    t.boolean "seyu", default: false
    t.text "desynced", default: [], null: false, array: true
    t.string "russian", default: "", null: false
    t.integer "mal_id"
    t.index ["name"], name: "index_people_on_name"
  end

  create_table "person_roles", id: :serial, force: :cascade do |t|
    t.integer "anime_id"
    t.integer "character_id"
    t.integer "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "manga_id"
    t.text "roles", default: [], null: false, array: true
    t.index ["anime_id"], name: "index_person_roles_on_anime_id"
    t.index ["character_id"], name: "index_person_roles_on_character_id"
    t.index ["manga_id"], name: "index_person_roles_on_manga_id"
    t.index ["person_id"], name: "index_person_roles_on_person_id"
    t.index ["roles"], name: "index_person_roles_on_roles", using: :gin
  end

  create_table "pg_cache_data", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.binary "blob"
    t.index ["key"], name: "index_pg_cache_data_on_key", unique: true
  end

  create_table "pghero_query_stats", force: :cascade do |t|
    t.text "database"
    t.text "user"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.bigint "calls"
    t.datetime "captured_at"
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "pghero_space_stats", force: :cascade do |t|
    t.text "database"
    t.text "schema"
    t.text "relation"
    t.bigint "size"
    t.datetime "captured_at"
    t.index ["database", "captured_at"], name: "index_pghero_space_stats_on_database_and_captured_at"
  end

  create_table "poll_variants", force: :cascade do |t|
    t.bigint "poll_id", null: false
    t.text "label"
    t.integer "cached_votes_total", default: 0
    t.index ["poll_id"], name: "index_poll_variants_on_poll_id"
  end

  create_table "polls", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "text", null: false
    t.string "width", default: "limited", null: false
    t.index ["user_id"], name: "index_polls_on_user_id"
  end

  create_table "proxies", id: false, force: :cascade do |t|
    t.string "ip", limit: 255
    t.integer "port"
  end

  create_table "publishers", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "desynced", default: [], null: false, array: true
  end

  create_table "recommendation_ignores", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "target_id"
    t.string "target_type", limit: 255
    t.index ["user_id", "target_id", "target_type"], name: "index_recommendation_ignores_on_entry", unique: true
  end

  create_table "related_animes", id: :serial, force: :cascade do |t|
    t.integer "source_id"
    t.integer "anime_id"
    t.string "relation", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "manga_id"
    t.index ["source_id"], name: "index_related_animes_on_source_id"
  end

  create_table "related_mangas", id: :serial, force: :cascade do |t|
    t.integer "source_id"
    t.integer "anime_id"
    t.integer "manga_id"
    t.string "relation", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["source_id", "manga_id"], name: "index_related_mangas_on_source_id_and_manga_id"
  end

  create_table "reviews", id: :serial, force: :cascade do |t|
    t.integer "target_id", null: false
    t.string "target_type", null: false
    t.integer "user_id", null: false
    t.text "text", null: false
    t.integer "overall"
    t.integer "storyline"
    t.integer "music"
    t.integer "characters"
    t.integer "animation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "comment_id"
    t.string "source"
    t.string "moderation_state", default: "pending", null: false
    t.integer "approver_id"
    t.string "locale", null: false
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.datetime "changed_at"
    t.index ["target_id", "target_type"], name: "index_reviews_on_target_id_and_target_type"
  end

  create_table "screenshots", id: :serial, force: :cascade do |t|
    t.string "image_file_name", limit: 255
    t.string "image_content_type", limit: 255
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.integer "anime_id"
    t.string "url", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position", null: false
    t.string "status", limit: 255
    t.integer "width"
    t.integer "height"
    t.index ["anime_id", "url"], name: "index_screenshots_on_anime_id_and_url", unique: true
  end

  create_table "similar_animes", id: :serial, force: :cascade do |t|
    t.integer "src_id"
    t.integer "dst_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["src_id"], name: "index_similar_animes_on_src_id"
  end

  create_table "similar_mangas", id: :serial, force: :cascade do |t|
    t.integer "src_id"
    t.integer "dst_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["src_id"], name: "index_similar_mangas_on_src_id"
  end

  create_table "studios", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "short_name", limit: 500000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "japanese", limit: 500000
    t.string "image_file_name", limit: 255
    t.string "image_content_type", limit: 255
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.integer "ani_db_id"
    t.string "ani_db_name", limit: 500000
    t.string "description_ru", limit: 16384
    t.string "description_en", limit: 16384
    t.string "website"
    t.boolean "is_visible", null: false
    t.boolean "is_publisher", default: false, null: false
    t.boolean "is_verified", default: false, null: false
    t.text "desynced", default: [], null: false, array: true
  end

  create_table "styles", id: :serial, force: :cascade do |t|
    t.integer "owner_id", null: false
    t.string "owner_type", null: false
    t.string "name", default: "", null: false
    t.text "css", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "compiled_css"
    t.text "imports", array: true
  end

  create_table "summaries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "anime_id"
    t.bigint "manga_id"
    t.text "body", null: false
    t.string "tone", null: false
    t.boolean "is_written_before_release", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comments_count", default: 0, null: false
    t.integer "cached_votes_up", default: 0, null: false
    t.integer "cached_votes_down", default: 0, null: false
    t.datetime "changed_at"
    t.index ["anime_id"], name: "index_summaries_on_anime_id"
    t.index ["manga_id"], name: "index_summaries_on_manga_id"
    t.index ["user_id", "anime_id"], name: "index_summaries_on_user_id_and_anime_id", unique: true, where: "(anime_id IS NOT NULL)"
    t.index ["user_id", "manga_id"], name: "index_summaries_on_user_id_and_manga_id", unique: true, where: "(manga_id IS NOT NULL)"
    t.index ["user_id"], name: "index_summaries_on_user_id"
  end

  create_table "summary_viewings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "viewed_id", null: false
    t.index ["user_id", "viewed_id"], name: "index_summary_viewings_on_user_id_and_viewed_id", unique: true
    t.index ["viewed_id"], name: "index_summary_viewings_on_viewed_id"
  end

  create_table "svds", id: :serial, force: :cascade do |t|
    t.binary "entry_ids"
    t.binary "lsa"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scale", limit: 255, default: "full"
    t.string "kind", limit: 255
    t.binary "user_ids"
    t.string "normalization"
  end

  create_table "topic_ignores", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_topic_ignores_on_topic_id"
    t.index ["user_id", "topic_id"], name: "index_topic_ignores_on_user_id_and_topic_id", unique: true
  end

  create_table "topic_viewings", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "viewed_id", null: false
    t.index ["user_id", "viewed_id"], name: "index_topic_viewings_on_user_id_and_viewed_id", unique: true
    t.index ["viewed_id"], name: "index_topic_viewings_on_viewed_id"
  end

  create_table "topics", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.integer "user_id", null: false
    t.integer "forum_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type", limit: 255
    t.text "body"
    t.boolean "generated", default: false
    t.integer "linked_id"
    t.string "linked_type", limit: 255
    t.boolean "processed", default: false
    t.string "action", limit: 255
    t.string "value", limit: 255
    t.integer "comments_count", default: 0
    t.boolean "broadcast", default: false
    t.string "locale", null: false
    t.datetime "commented_at"
    t.text "tags", default: [], null: false, array: true
    t.boolean "is_closed", default: false, null: false
    t.boolean "is_pinned", default: false, null: false
    t.index ["generated", "type", "created_at"], name: "index_entries_on_in_forum_and_type_and_created_at"
    t.index ["is_pinned"], name: "index_topics_on_is_pinned", where: "(is_pinned = true)"
    t.index ["linked_id", "linked_type", "comments_count", "generated"], name: "entries_total_select"
    t.index ["type", "forum_id"], name: "index_topics_on_type_and_forum_id"
    t.index ["type", "linked_id", "linked_type"], name: "i_entries_type_linked_type_linked_id"
    t.index ["type", "updated_at"], name: "index_topics_on_type_and_updated_at"
    t.index ["type", "user_id"], name: "i_entries_type_user_id"
    t.index ["updated_at"], name: "index_topics_on_updated_at"
  end

  create_table "user_histories", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "target_id"
    t.string "target_type", limit: 255
    t.string "action", limit: 255
    t.string "value", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "prior_value", limit: 255
    t.index ["target_type", "user_id", "id"], name: "index_user_histories_on_target_type_and_user_id_and_id"
    t.index ["updated_at"], name: "index_user_histories_on_updated_at"
    t.index ["user_id", "action"], name: "user_histories_UserDataFetcherBase_latest_import_index", where: "((action)::text = ANY (ARRAY[('mal_anime_import'::character varying)::text, ('ap_anime_import'::character varying)::text, ('anime_history_clear'::character varying)::text, ('mal_manga_import'::character varying)::text, ('ap_manga_import'::character varying)::text, ('manga_history_clear'::character varying)::text]))"
    t.index ["user_id"], name: "index_user_histories_on_user_id"
  end

  create_table "user_images", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "linked_id"
    t.string "linked_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name", limit: 255
    t.string "image_content_type", limit: 255
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.integer "width"
    t.integer "height"
  end

  create_table "user_nickname_changes", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "value", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false, null: false
    t.index ["user_id", "value"], name: "index_user_nickname_changes_on_user_id_and_value", unique: true
  end

  create_table "user_preferences", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "anime_in_profile", default: true
    t.boolean "manga_in_profile", default: true
    t.string "default_sort", limit: 255, default: "name", null: false
    t.boolean "comments_in_profile", default: true
    t.date "statistics_start_on"
    t.boolean "russian_names", default: true
    t.boolean "about_on_top", default: false
    t.boolean "russian_genres", default: true, null: false
    t.boolean "is_show_smileys", default: true
    t.boolean "show_social_buttons", default: true
    t.boolean "show_hentai_images", default: false
    t.string "list_privacy", limit: 255, default: "public"
    t.boolean "volumes_in_manga", default: false, null: false
    t.boolean "is_comments_auto_collapsed", default: true
    t.boolean "is_comments_auto_loaded", default: true
    t.string "body_width", default: "x1200", null: false
    t.text "forums", default: [], null: false, array: true
    t.string "comment_policy", default: "users", null: false
    t.boolean "apply_user_styles", default: true, null: false
    t.integer "favorites_in_profile", default: 8, null: false
    t.boolean "achievements_in_profile", default: true, null: false
    t.string "dashboard_type", default: "new", null: false
    t.boolean "is_shiki_editor", default: false, null: false
    t.index ["user_id"], name: "index_profile_settings_on_user_id"
  end

  create_table "user_rate_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.jsonb "diff"
    t.bigint "oauth_application_id"
    t.string "user_agent"
    t.inet "ip"
    t.datetime "created_at"
    t.index ["oauth_application_id"], name: "index_user_rate_logs_on_oauth_application_id"
    t.index ["target_type", "target_id"], name: "index_user_rate_logs_on_target_type_and_target_id"
    t.index ["user_id", "id"], name: "index_user_rate_logs_on_user_id_and_id"
  end

  create_table "user_rates", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "target_id", null: false
    t.integer "score", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "episodes", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "target_type", null: false
    t.integer "volumes", default: 0, null: false
    t.integer "chapters", default: 0, null: false
    t.string "text", limit: 16384
    t.integer "rewatches", default: 0, null: false
    t.index ["target_id", "target_type"], name: "i_target"
    t.index ["user_id", "target_id", "target_type"], name: "index_user_rates_on_user_id_and_target_id_and_target_type", unique: true
  end

  create_table "user_tokens", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "token"
    t.string "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "nickname", limit: 255
    t.index ["uid"], name: "index_user_tokens_on_uid"
    t.index ["user_id"], name: "index_user_tokens_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", limit: 128
    t.string "reset_password_token", limit: 255
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "nickname", limit: 255
    t.string "location", limit: 255
    t.datetime "last_online_at"
    t.text "about", default: "", null: false
    t.string "sex", limit: 255
    t.string "website"
    t.string "avatar_file_name", limit: 255
    t.string "avatar_content_type", limit: 255
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.date "birth_on"
    t.datetime "read_only_at"
    t.boolean "can_vote_1", default: false, null: false
    t.boolean "can_vote_2", default: false, null: false
    t.boolean "can_vote_3", default: false, null: false
    t.datetime "reset_password_sent_at"
    t.string "remember_token", limit: 255
    t.string "locale", default: "ru", null: false
    t.string "locale_from_host", default: "ru", null: false
    t.integer "style_id"
    t.string "roles", limit: 4096, default: [], null: false, array: true
    t.text "notification_settings", default: [], null: false, array: true
    t.datetime "activity_at"
    t.datetime "rate_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["roles"], name: "index_users_on_roles", using: :gin
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "user_id"
    t.string "state", null: false
    t.datetime "created_at"
    t.jsonb "item_diff"
    t.integer "moderator_id"
    t.text "reason"
    t.string "type"
    t.datetime "updated_at"
    t.integer "associated_id"
    t.string "associated_type"
    t.index ["associated_id", "associated_type"], name: "index_versions_on_associated_id_and_associated_type"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["state"], name: "index_versions_on_state"
    t.index ["user_id", "state"], name: "index_versions_on_user_id_and_state"
  end

  create_table "videos", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "url", null: false
    t.integer "uploader_id"
    t.integer "anime_id"
    t.string "kind", null: false
    t.string "state", limit: 255, default: "uploaded", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url", null: false
    t.string "player_url", null: false
    t.string "hosting", null: false
    t.index ["anime_id"], name: "index_videos_on_anime_id"
  end

  create_table "votes", force: :cascade do |t|
    t.string "votable_type", null: false
    t.bigint "votable_id", null: false
    t.string "voter_type", null: false
    t.bigint "voter_id", null: false
    t.boolean "vote_flag"
    t.string "vote_scope"
    t.integer "vote_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
    t.index ["votable_type", "votable_id"], name: "index_votes_on_votable_type_and_votable_id"
    t.index ["voter_id", "votable_id"], name: "index_votes_on_voter_id_and_votable_id"
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"
    t.index ["voter_type", "voter_id"], name: "index_votes_on_voter_type_and_voter_id"
  end

  create_table "webm_videos", id: :serial, force: :cascade do |t|
    t.string "url", null: false
    t.string "state", null: false
    t.string "thumbnail_file_name"
    t.string "thumbnail_content_type"
    t.integer "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["url"], name: "index_webm_videos_on_url", unique: true
  end

  add_foreign_key "abuse_requests", "comments"
  add_foreign_key "abuse_requests", "users"
  add_foreign_key "abuse_requests", "users", column: "approver_id"
  add_foreign_key "bans", "users"
  add_foreign_key "bans", "users", column: "moderator_id"
  add_foreign_key "collection_roles", "collections"
  add_foreign_key "collection_roles", "users"
  add_foreign_key "comment_viewings", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "summaries", "animes"
  add_foreign_key "summaries", "mangas"
  add_foreign_key "summaries", "users"
  add_foreign_key "summary_viewings", "users"
  add_foreign_key "topic_viewings", "users"
end
