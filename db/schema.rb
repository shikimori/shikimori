# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151202104116) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "abuse_requests", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.string   "kind",        limit: 255
    t.boolean  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",       limit: 255
    t.integer  "approver_id"
    t.string   "reason"
  end

  add_index "abuse_requests", ["comment_id", "kind", "value"], name: "index_abuse_requests_on_comment_id_and_kind_and_value", unique: true, where: "((state)::text = 'pending'::text)", using: :btree
  add_index "abuse_requests", ["state", "kind"], name: "index_abuse_requests_on_state_and_kind", using: :btree

  create_table "anime_calendars", force: :cascade do |t|
    t.integer  "anime_id"
    t.integer  "episode"
    t.datetime "start_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "anime_calendars", ["anime_id", "episode"], name: "index_anime_calendars_on_anime_id_and_episode", unique: true, using: :btree

  create_table "anime_histories", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "anime_id"
    t.string   "action",     limit: 255
    t.string   "value",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "processed",              default: false
    t.integer  "topic_id",               default: 0,     null: false
  end

  create_table "anime_links", force: :cascade do |t|
    t.integer  "anime_id"
    t.string   "service",    limit: 255, null: false
    t.string   "identifier", limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "anime_links", ["anime_id", "service", "identifier"], name: "index_anime_links_on_anime_id_and_service_and_identifier", unique: true, using: :btree

  create_table "anime_video_authors", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "anime_video_authors", ["name"], name: "index_anime_video_authors_on_name", using: :btree

  create_table "anime_video_reports", force: :cascade do |t|
    t.integer  "anime_video_id"
    t.integer  "user_id"
    t.integer  "approver_id"
    t.string   "kind",           limit: 255
    t.string   "state",          limit: 255
    t.string   "user_agent",     limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "message",        limit: 1000
  end

  add_index "anime_video_reports", ["anime_video_id", "kind", "state"], name: "index_anime_video_reports_on_anime_video_id_and_kind_and_state", using: :btree
  add_index "anime_video_reports", ["user_id", "state"], name: "index_anime_video_reports_on_user_id_and_state", using: :btree

  create_table "anime_videos", force: :cascade do |t|
    t.integer  "anime_id"
    t.string   "url",                   limit: 1000
    t.string   "source",                limit: 1000
    t.integer  "episode"
    t.string   "kind",                  limit: 255
    t.string   "language",              limit: 255
    t.integer  "anime_video_author_id"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "state",                 limit: 255,  default: "working", null: false
    t.integer  "watch_view_count"
  end

  add_index "anime_videos", ["anime_id"], name: "index_anime_videos_on_anime_id", using: :btree
  add_index "anime_videos", ["anime_video_author_id"], name: "index_anime_videos_on_anime_video_author_id", using: :btree

  create_table "animes", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.text     "description_ru"
    t.text     "description_en"
    t.string   "kind",               limit: 255
    t.integer  "episodes",                       default: 0,     null: false
    t.integer  "duration"
    t.text     "english"
    t.text     "japanese"
    t.text     "synonyms"
    t.decimal  "score",                          default: 0.0,   null: false
    t.integer  "ranked"
    t.integer  "popularity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.date     "aired_on"
    t.date     "released_on"
    t.string   "status",             limit: 255
    t.string   "rating",             limit: 255
    t.integer  "episodes_aired",                 default: 0,     null: false
    t.integer  "editor_id"
    t.string   "russian",            limit: 255
    t.integer  "world_art_id",                   default: 0
    t.text     "world_art_synonyms"
    t.integer  "ani_db_id",                      default: 0
    t.string   "mal_scores",         limit: 255
    t.string   "ani_db_scores",      limit: 255
    t.string   "world_art_scores",   limit: 255
    t.boolean  "censored",                       default: false
    t.datetime "imported_at"
    t.datetime "next_episode_at"
    t.string   "tags",               limit: 255
    t.string   "source",             limit: 255
    t.string   "torrents_name",      limit: 255
    t.float    "site_score",                     default: 0.0,   null: false
    t.text     "desynced",                       default: [],    null: false, array: true
  end

  add_index "animes", ["kind"], name: "index_animes_on_kind", using: :btree
  add_index "animes", ["name"], name: "index_animes_on_name", using: :btree
  add_index "animes", ["russian"], name: "index_animes_on_russian", using: :btree
  add_index "animes", ["score"], name: "index_animes_on_score", using: :btree
  add_index "animes", ["status", "score", "kind"], name: "anime_online_dashboard_query", using: :btree

  create_table "animes_genres", id: false, force: :cascade do |t|
    t.integer "anime_id"
    t.integer "genre_id"
  end

  add_index "animes_genres", ["anime_id"], name: "index_animes_genres_on_anime_id", using: :btree

  create_table "animes_studios", id: false, force: :cascade do |t|
    t.integer "anime_id"
    t.integer "studio_id"
  end

  add_index "animes_studios", ["anime_id"], name: "index_animes_studios_on_anime_id", using: :btree

  create_table "bans", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.integer  "abuse_request_id"
    t.integer  "moderator_id"
    t.integer  "duration"
    t.text     "reason"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "bans", ["user_id"], name: "index_bans_on_user_id", using: :btree

  create_table "blob_datas", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blob_datas", ["key"], name: "index_blob_datas_on_key", unique: true, using: :btree

  create_table "characters", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "japanese",           limit: 255
    t.string   "fullname",           limit: 255
    t.text     "description_ru"
    t.text     "description_en"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "imported_at"
    t.string   "tags",               limit: 255
    t.string   "russian"
    t.string   "source",             limit: 255
    t.text     "desynced",                       default: [], null: false, array: true
  end

  add_index "characters", ["name"], name: "index_characters_on_name", using: :btree

  create_table "comment_views", force: :cascade do |t|
    t.integer "user_id"
    t.integer "comment_id"
  end

  add_index "comment_views", ["comment_id"], name: "index_comment_views_on_comment_id", using: :btree
  add_index "comment_views", ["user_id", "comment_id"], name: "index_comment_views_on_user_id_and_comment_id", unique: true, using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type", limit: 15
    t.text     "body"
    t.integer  "user_id",                                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "review",                      default: false
    t.boolean  "offtopic",                    default: false
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["created_at"], name: "index_comments_on_created_at", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "contest_links", force: :cascade do |t|
    t.integer  "contest_id"
    t.integer  "linked_id"
    t.string   "linked_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contest_links", ["linked_id", "linked_type", "contest_id"], name: "index_contest_links_on_linked_id_and_linked_type_and_contest_id", using: :btree

  create_table "contest_matches", force: :cascade do |t|
    t.integer  "round_id"
    t.string   "state",       limit: 255, default: "created"
    t.string   "group",       limit: 255
    t.integer  "left_id"
    t.string   "left_type",   limit: 255
    t.integer  "right_id"
    t.string   "right_type",  limit: 255
    t.date     "started_on"
    t.date     "finished_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "winner_id"
  end

  add_index "contest_matches", ["round_id"], name: "index_contest_votes_on_contest_round_id", using: :btree

  create_table "contest_rounds", force: :cascade do |t|
    t.integer  "contest_id"
    t.string   "state",      limit: 255, default: "created"
    t.integer  "number"
    t.boolean  "additional"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contest_rounds", ["contest_id"], name: "index_contest_rounds_on_contest_id", using: :btree

  create_table "contest_suggestions", force: :cascade do |t|
    t.integer  "contest_id"
    t.integer  "user_id"
    t.integer  "item_id"
    t.string   "item_type",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "contest_suggestions", ["contest_id"], name: "index_contest_suggestions_on_contest_id", using: :btree
  add_index "contest_suggestions", ["user_id"], name: "index_contest_suggestions_on_user_id", using: :btree

  create_table "contest_user_votes", force: :cascade do |t|
    t.integer "contest_match_id",             null: false
    t.integer "user_id",                      null: false
    t.integer "item_id",                      null: false
    t.string  "ip",               limit: 255, null: false
  end

  add_index "contest_user_votes", ["contest_match_id", "ip"], name: "index_contest_user_votes_on_contest_vote_id_and_ip", unique: true, using: :btree
  add_index "contest_user_votes", ["contest_match_id", "item_id"], name: "index_contest_user_votes_on_contest_vote_id_and_item_id", using: :btree
  add_index "contest_user_votes", ["contest_match_id", "user_id"], name: "index_contest_user_votes_on_contest_vote_id_and_user_id", unique: true, using: :btree
  add_index "contest_user_votes", ["contest_match_id"], name: "index_contest_user_votes_on_contest_vote_id", using: :btree

  create_table "contests", force: :cascade do |t|
    t.string   "title",                limit: 255
    t.text     "description"
    t.integer  "user_id"
    t.string   "state",                limit: 255, default: "created"
    t.date     "started_on"
    t.integer  "matches_per_round"
    t.integer  "match_duration"
    t.integer  "matches_interval"
    t.integer  "wave_days"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink",            limit: 255
    t.date     "finished_on"
    t.string   "user_vote_key",        limit: 255
    t.string   "strategy_type",        limit: 255, default: "Contest::DoubleEliminationStrategy", null: false
    t.integer  "suggestions_per_user"
    t.string   "member_type",          limit: 255, default: "anime"
  end

  add_index "contests", ["state", "started_on", "finished_on"], name: "index_contests_on_state_and_started_on_and_finished_on", using: :btree

  create_table "cosplay_galleries", force: :cascade do |t|
    t.string   "cos_rain_id",          limit: 255
    t.string   "target",               limit: 255
    t.text     "description_cos_rain"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirmed",                        default: false, null: false
    t.boolean  "deleted",                          default: false, null: false
    t.string   "source",               limit: 255
    t.integer  "user_id"
  end

  add_index "cosplay_galleries", ["cos_rain_id"], name: "index_cosplay_galleries_on_cos_rain_id", unique: true, using: :btree

  create_table "cosplay_gallery_links", force: :cascade do |t|
    t.integer  "linked_id"
    t.string   "linked_type",        limit: 255
    t.integer  "cosplay_gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cosplay_gallery_links", ["cosplay_gallery_id", "linked_type"], name: "i_cosplay_gallery_id_linked_type", using: :btree
  add_index "cosplay_gallery_links", ["linked_id", "linked_type", "cosplay_gallery_id"], name: "index_cosplay_gallery_links_on_l_id_and_l_type_and_cg_id", unique: true, using: :btree

  create_table "cosplay_images", force: :cascade do |t|
    t.integer  "cosplay_gallery_id"
    t.string   "url",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "deleted",                        default: false, null: false
    t.integer  "position"
  end

  add_index "cosplay_images", ["cosplay_gallery_id", "deleted"], name: "i_cosplay_images_gallery_id_deleted", using: :btree

  create_table "cosplayers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "website",    limit: 255
    t.string   "image_url",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cosplayers", ["name"], name: "index_cosplayers_on_name", unique: true, using: :btree

  create_table "danbooru_tags", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ambiguous"
  end

  create_table "devices", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.string   "token",      limit: 255, null: false
    t.integer  "platform",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 255
  end

  create_table "entries", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.string   "permalink",      limit: 255
    t.integer  "user_id"
    t.integer  "section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",           limit: 255
    t.text     "text"
    t.boolean  "generated",                  default: false
    t.integer  "linked_id"
    t.string   "linked_type",    limit: 255
    t.boolean  "processed",                  default: false
    t.string   "action",         limit: 255
    t.string   "value",          limit: 255
    t.integer  "comments_count",             default: 0
    t.boolean  "broadcast",                  default: false
  end

  add_index "entries", ["generated", "type", "created_at"], name: "index_entries_on_in_forum_and_type_and_created_at", using: :btree
  add_index "entries", ["linked_id", "linked_type", "comments_count", "generated"], name: "entries_total_select", using: :btree
  add_index "entries", ["type", "linked_id", "linked_type"], name: "i_entries_type_linked_type_linked_id", using: :btree
  add_index "entries", ["type", "updated_at"], name: "index_entries_on_type_and_updated_at", using: :btree
  add_index "entries", ["type", "user_id"], name: "i_entries_type_user_id", using: :btree
  add_index "entries", ["updated_at"], name: "index_entries_on_updated_at", using: :btree

  create_table "entry_views", force: :cascade do |t|
    t.integer "user_id"
    t.integer "entry_id"
  end

  add_index "entry_views", ["entry_id"], name: "index_entry_views_on_entry_id", using: :btree
  add_index "entry_views", ["user_id", "entry_id"], name: "index_entry_views_on_user_id_and_entry_id", unique: true, using: :btree

  create_table "episode_notifications", force: :cascade do |t|
    t.integer  "anime_id"
    t.integer  "episode"
    t.boolean  "is_raw"
    t.boolean  "is_subtitles"
    t.boolean  "is_fandub"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_unknown"
  end

  add_index "episode_notifications", ["anime_id"], name: "index_episode_notifications_on_anime_id", using: :btree

  create_table "favourites", force: :cascade do |t|
    t.integer  "linked_id"
    t.string   "linked_type", limit: 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind",        limit: 255
  end

  add_index "favourites", ["linked_id", "linked_type", "kind", "user_id"], name: "uniq_favourites", unique: true, using: :btree
  add_index "favourites", ["linked_type", "linked_id"], name: "i_linked", using: :btree
  add_index "favourites", ["user_id"], name: "index_favourites_on_user_id", using: :btree

  create_table "friend_links", force: :cascade do |t|
    t.integer  "src_id"
    t.integer  "dst_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friend_links", ["src_id"], name: "index_friend_links_on_src_id", using: :btree

  create_table "genres", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "russian",     limit: 255
    t.integer  "position"
    t.integer  "seo",                     default: 99
    t.text     "description"
    t.string   "kind",                                 null: false
    t.integer  "mal_id",                               null: false
  end

  create_table "genres_mangas", id: false, force: :cascade do |t|
    t.integer "manga_id"
    t.integer "genre_id"
  end

  add_index "genres_mangas", ["manga_id"], name: "index_genres_mangas_on_manga_id", using: :btree

  create_table "group_bans", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_bans", ["group_id", "user_id"], name: "index_group_bans_on_group_id_and_user_id", unique: true, using: :btree
  add_index "group_bans", ["user_id"], name: "index_group_bans_on_user_id", using: :btree

  create_table "group_invites", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "src_id"
    t.integer  "dst_id"
    t.string   "status",     limit: 255, default: "Pending"
    t.integer  "message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_invites", ["group_id", "dst_id", "status"], name: "uniq_group_invites", unique: true, using: :btree

  create_table "group_links", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "linked_id"
    t.string   "linked_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_roles", force: :cascade do |t|
    t.string   "role",       limit: 255, default: "member"
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_roles", ["user_id", "group_id"], name: "uniq_user_in_group", unique: true, using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.integer  "join_policy",                   default: 1,           null: false
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "logo_file_name",    limit: 255
    t.string   "logo_content_type", limit: 255
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "upload_policy",     limit: 255, default: "ByMembers"
    t.integer  "group_roles_count",             default: 0
    t.string   "permalink",         limit: 255
    t.boolean  "display_images",                default: true
    t.integer  "comment_policy",                default: 1,           null: false
    t.boolean  "is_censored",                   default: false,       null: false
  end

  create_table "ignores", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type",         limit: 255
    t.integer  "uploader_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "images", ["owner_type", "owner_id"], name: "index_images_on_owner_type_and_owner_id", using: :btree

  create_table "manga_chapters", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "url",        limit: 255
    t.integer  "manga_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manga_pages", force: :cascade do |t|
    t.string   "url",                limit: 255
    t.integer  "number"
    t.integer  "manga_chapter_id"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mangas", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.text     "description_ru"
    t.text     "description_en"
    t.string   "kind",               limit: 255
    t.integer  "volumes",                                                default: 0,     null: false
    t.integer  "volumes_aired",                                          default: 0,     null: false
    t.integer  "chapters",                                               default: 0,     null: false
    t.integer  "chapters_aired",                                         default: 0,     null: false
    t.string   "status",             limit: 255
    t.text     "english"
    t.text     "japanese"
    t.text     "synonyms"
    t.string   "russian",            limit: 255
    t.decimal  "score",                                                  default: 0.0,   null: false
    t.integer  "ranked"
    t.integer  "popularity"
    t.string   "rating",             limit: 255
    t.date     "aired_on"
    t.date     "released_on"
    t.date     "imported_at"
    t.string   "mal_scores",         limit: 255
    t.integer  "editor_id"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "censored",                                               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tags",               limit: 255
    t.string   "source",             limit: 255
    t.string   "read_manga_id",      limit: 255
    t.decimal  "read_manga_scores",              precision: 8, scale: 2, default: 0.0
    t.float    "site_score",                                             default: 0.0,   null: false
    t.datetime "parsed_at"
    t.text     "desynced",                                               default: [],    null: false, array: true
  end

  add_index "mangas", ["kind"], name: "index_mangas_on_kind", using: :btree
  add_index "mangas", ["name"], name: "index_mangas_on_name", using: :btree
  add_index "mangas", ["russian"], name: "index_mangas_on_russian", using: :btree

  create_table "mangas_publishers", id: false, force: :cascade do |t|
    t.integer "manga_id"
    t.integer "publisher_id"
  end

  add_index "mangas_publishers", ["manga_id"], name: "index_mangas_publishers_on_manga_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.string   "kind",               limit: 255
    t.text     "body"
    t.boolean  "read",                           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted_by_from",             default: false
    t.boolean  "is_deleted_by_to",               default: false
    t.boolean  "emailed",                        default: false
    t.integer  "linked_id",                      default: 0,     null: false
    t.string   "linked_type",        limit: 255
  end

  add_index "messages", ["from_id", "is_deleted_by_from", "kind"], name: "private_and_notifications", using: :btree
  add_index "messages", ["linked_type", "linked_id"], name: "index_messages_on_linked_type_and_linked_id", using: :btree
  add_index "messages", ["to_id", "kind", "read"], name: "messages_for_profile", using: :btree

  create_table "people", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "japanese",           limit: 255
    t.text     "description"
    t.text     "description_mal"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.date     "birthday"
    t.string   "given_name",         limit: 255
    t.string   "family_name",        limit: 255
    t.string   "website",            limit: 255
    t.datetime "imported_at"
    t.boolean  "producer",                       default: false
    t.boolean  "mangaka",                        default: false
    t.boolean  "seyu",                           default: false
    t.text     "desynced",                       default: [],    null: false, array: true
    t.string   "russian"
  end

  add_index "people", ["name"], name: "index_people_on_name", using: :btree

  create_table "person_roles", force: :cascade do |t|
    t.string   "role",         limit: 255
    t.integer  "anime_id"
    t.integer  "character_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manga_id"
  end

  add_index "person_roles", ["anime_id"], name: "index_person_roles_on_anime_id", using: :btree
  add_index "person_roles", ["character_id"], name: "index_person_roles_on_character_id", using: :btree
  add_index "person_roles", ["manga_id"], name: "index_person_roles_on_manga_id", using: :btree
  add_index "person_roles", ["person_id"], name: "index_person_roles_on_person_id", using: :btree
  add_index "person_roles", ["role", "anime_id", "character_id"], name: "i_person_role_role_anime_id", using: :btree
  add_index "person_roles", ["role", "manga_id", "character_id"], name: "i_person_role_role_manga_id", using: :btree

  create_table "proxies", id: false, force: :cascade do |t|
    t.string  "ip",   limit: 255
    t.integer "port"
  end

  create_table "publishers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommendation_ignores", force: :cascade do |t|
    t.integer "user_id"
    t.integer "target_id"
    t.string  "target_type", limit: 255
  end

  add_index "recommendation_ignores", ["user_id", "target_id", "target_type"], name: "index_recommendation_ignores_on_entry", unique: true, using: :btree
  add_index "recommendation_ignores", ["user_id"], name: "index_recommendation_ignores_on_user_id", using: :btree

  create_table "related_animes", force: :cascade do |t|
    t.integer  "source_id"
    t.integer  "anime_id"
    t.string   "relation",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manga_id"
  end

  create_table "related_mangas", force: :cascade do |t|
    t.integer  "source_id"
    t.integer  "anime_id"
    t.integer  "manga_id"
    t.string   "relation",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "related_mangas", ["source_id", "manga_id"], name: "index_related_mangas_on_source_id_and_manga_id", using: :btree

  create_table "review_views", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "review_id"
  end

  add_index "review_views", ["user_id", "review_id"], name: "index_review_views_on_user_id_and_review_id", unique: true, using: :btree

  create_table "reviews", force: :cascade do |t|
    t.integer  "target_id"
    t.string   "target_type", limit: 255
    t.integer  "user_id"
    t.text     "text"
    t.integer  "overall"
    t.integer  "storyline"
    t.integer  "music"
    t.integer  "characters"
    t.integer  "animation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comment_id"
    t.string   "source",      limit: 255
    t.string   "state",       limit: 255, default: "pending"
    t.integer  "approver_id"
  end

  add_index "reviews", ["target_id", "target_type"], name: "index_reviews_on_target_id_and_target_type", using: :btree

  create_table "screenshots", force: :cascade do |t|
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "anime_id"
    t.string   "url",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",                       null: false
    t.string   "status",             limit: 255
  end

  add_index "screenshots", ["anime_id", "url"], name: "index_screenshots_on_anime_id_and_url", unique: true, using: :btree
  add_index "screenshots", ["anime_id"], name: "index_screenshots_on_anime_id", using: :btree

  create_table "sections", force: :cascade do |t|
    t.integer  "position"
    t.string   "name",             limit: 255
    t.string   "description",      limit: 255
    t.string   "permalink",        limit: 255
    t.integer  "topics_count",                 default: 0
    t.integer  "posts_count",                  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "meta_title",       limit: 255
    t.string   "meta_keywords",    limit: 255
    t.string   "meta_description", limit: 255
    t.boolean  "is_visible"
  end

  create_table "similar_animes", force: :cascade do |t|
    t.integer  "src_id"
    t.integer  "dst_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "similar_animes", ["src_id"], name: "index_similar_animes_on_src_id", using: :btree

  create_table "similar_mangas", force: :cascade do |t|
    t.integer  "src_id"
    t.integer  "dst_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "similar_mangas", ["src_id"], name: "index_similar_mangas_on_src_id", using: :btree

  create_table "studios", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "short_name",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "japanese",           limit: 255
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "ani_db_id"
    t.string   "ani_db_name",        limit: 255
    t.text     "description"
    t.text     "ani_db_description"
    t.string   "website",            limit: 255
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "target_id"
    t.string   "target_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["user_id", "target_type"], name: "index_subscriptions_on_user_id_and_target_type", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "svds", force: :cascade do |t|
    t.binary   "entry_ids"
    t.binary   "lsa"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "scale",         limit: 255, default: "full"
    t.string   "kind",          limit: 255
    t.binary   "user_ids"
    t.string   "normalization"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 255
    t.datetime "created_at"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "user_changes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.string   "model",       limit: 255
    t.string   "column",      limit: 255
    t.text     "value"
    t.text     "prior"
    t.string   "status",      limit: 255, default: "Pending"
    t.integer  "approver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source",      limit: 255
    t.string   "action",      limit: 255
    t.string   "reason"
  end

  create_table "user_histories", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "target_id"
    t.string   "target_type", limit: 255
    t.string   "action",      limit: 255
    t.string   "value",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "prior_value", limit: 255
  end

  add_index "user_histories", ["target_type", "user_id"], name: "i_user_target", using: :btree
  add_index "user_histories", ["updated_at"], name: "index_user_histories_on_updated_at", using: :btree
  add_index "user_histories", ["user_id"], name: "index_user_histories_on_user_id", using: :btree

  create_table "user_images", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "linked_id"
    t.string   "linked_type",        limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "width"
    t.integer  "height"
  end

  add_index "user_images", ["linked_id", "linked_type"], name: "index_user_images_on_linked_id_and_linked_type", using: :btree

  create_table "user_nickname_changes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "value",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",             default: false
  end

  add_index "user_nickname_changes", ["user_id", "value"], name: "index_user_nickname_changes_on_user_id_and_value", unique: true, using: :btree
  add_index "user_nickname_changes", ["user_id"], name: "index_user_nickname_changes_on_user_id", using: :btree

  create_table "user_preferences", force: :cascade do |t|
    t.integer "user_id"
    t.boolean "anime_in_profile",                       default: true
    t.boolean "manga_in_profile",                       default: true
    t.string  "default_sort",               limit: 255, default: "name",   null: false
    t.boolean "comments_in_profile",                    default: true
    t.boolean "postload_in_catalog",                    default: true
    t.date    "statistics_start_on"
    t.boolean "russian_names",                          default: true
    t.boolean "about_on_top",                           default: false
    t.boolean "russian_genres",                         default: true,     null: false
    t.boolean "menu_contest",                           default: true,     null: false
    t.string  "page_background",            limit: 255
    t.boolean "page_border",                            default: false
    t.string  "body_background",            limit: 512
    t.boolean "show_smileys",                           default: true
    t.boolean "show_social_buttons",                    default: true
    t.boolean "show_hentai_images",                     default: false
    t.string  "list_privacy",               limit: 255, default: "public"
    t.boolean "volumes_in_manga",                       default: false,    null: false
    t.boolean "is_comments_auto_collapsed",             default: true
    t.boolean "is_comments_auto_loaded",                default: true
    t.string  "body_width",                             default: "x1200",  null: false
  end

  add_index "user_preferences", ["user_id"], name: "index_profile_settings_on_user_id", using: :btree

  create_table "user_rates", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "target_id"
    t.integer  "score",                    default: 0, null: false
    t.integer  "status",                   default: 0, null: false
    t.integer  "episodes",                 default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "target_type", limit: 255
    t.integer  "volumes",                  default: 0, null: false
    t.integer  "chapters",                 default: 0, null: false
    t.string   "text",        limit: 2048
    t.integer  "rewatches",                default: 0, null: false
  end

  add_index "user_rates", ["target_id", "target_type"], name: "i_target", using: :btree
  add_index "user_rates", ["user_id", "target_id", "target_type"], name: "index_user_rates_on_user_id_and_target_id_and_target_type", unique: true, using: :btree

  create_table "user_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.string   "token",      limit: 255
    t.string   "secret",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname",   limit: 255
  end

  add_index "user_tokens", ["user_id"], name: "index_user_tokens_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255
    t.string   "encrypted_password",     limit: 128
    t.string   "reset_password_token",   limit: 255
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "name",                   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname",               limit: 255
    t.string   "location",               limit: 255
    t.integer  "notifications",                      default: 1601776
    t.datetime "last_online_at"
    t.text     "about"
    t.string   "sex",                    limit: 255
    t.string   "website",                limit: 255
    t.string   "avatar_file_name",       limit: 255
    t.string   "avatar_content_type",    limit: 255
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.date     "birth_on"
    t.datetime "read_only_at"
    t.boolean  "can_vote_1",                         default: false,     null: false
    t.boolean  "can_vote_2",                         default: false,     null: false
    t.boolean  "can_vote_3",                         default: false,     null: false
    t.datetime "reset_password_sent_at"
    t.string   "remember_token",         limit: 255
    t.string   "api_access_token"
    t.string   "language",                           default: "russian"
  end

  add_index "users", ["api_access_token"], name: "index_users_on_api_access_token", unique: true, using: :btree
  add_index "users", ["nickname"], name: "index_users_on_nickname", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",    limit: 255
    t.integer  "item_id"
    t.integer  "user_id"
    t.string   "state",        limit: 255
    t.datetime "created_at"
    t.json     "item_diff"
    t.integer  "moderator_id"
    t.string   "reason"
    t.string   "type"
    t.datetime "updated_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["state"], name: "index_versions_on_state", using: :btree
  add_index "versions", ["user_id", "state"], name: "index_versions_on_user_id_and_state", using: :btree

  create_table "videos", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "url",         limit: 255
    t.integer  "uploader_id"
    t.integer  "anime_id"
    t.string   "kind",        limit: 255
    t.string   "state",       limit: 255,  default: "uploaded", null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "image_url",   limit: 1024
    t.string   "player_url",  limit: 1024
    t.string   "hosting",     limit: 255
  end

  add_index "videos", ["anime_id"], name: "index_videos_on_anime_id", using: :btree

  create_table "votes", force: :cascade do |t|
    t.boolean  "voting",                    default: false
    t.datetime "created_at",                                null: false
    t.integer  "voteable_id"
    t.string   "voteable_type", limit: 255
    t.integer  "user_id"
  end

  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree
  add_index "votes", ["voteable_id"], name: "index_votes_on_voteable_id", using: :btree
  add_index "votes", ["voteable_type"], name: "index_votes_on_voteable_type", using: :btree

  create_table "webm_videos", force: :cascade do |t|
    t.string   "url",                    limit: 1024, null: false
    t.string   "state",                               null: false
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "webm_videos", ["url"], name: "index_webm_videos_on_url", unique: true, using: :btree

end
