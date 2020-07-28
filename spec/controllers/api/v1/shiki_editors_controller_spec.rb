describe Api::V1::ShikiEditorsController do
  include_context :authenticated

  describe '#show' do
    before { stub_const "#{described_class.name}::LIMIT_PER_REQUEST", limit_per_request }

    subject! { get :show, params: params }

    let(:limit_per_request) { 100 }
    let(:params) do
      {
        anime: anime.id.to_s,
        manga: [manga_1.id, manga_2.id].join(','),
        character: character.id.to_s,
        person: person.id.to_s,
        user_image: user_image.id.to_s,
        user: user.id.to_s,
        comment: comment.id.to_s,
        message: message.id.to_s,
        topic: topic.id.to_s
      }
    end
    let(:anime) { create :anime }
    let(:manga_1) { create :manga }
    let(:manga_2) { create :ranobe }
    let(:character) { create :character }
    let(:person) { create :person }
    let(:user_image) { create :user_image }
    let(:comment) { create :comment, user: user }
    let(:message) { create :message, from: user }
    let(:topic) { create :topic }

    it do
      expect(json).to eq(
        anime: {
          anime.id.to_s => {
            'id' => anime.id,
            'text' => anime.russian,
            'url' => anime_url(anime)
          }
        },
        manga: {
          manga_1.id.to_s => {
            'id' => manga_1.id,
            'text' => manga_1.russian,
            'url' => manga_url(manga_1)
          },
          manga_2.id.to_s => {
            'id' => manga_2.id,
            'text' => manga_2.russian,
            'url' => ranobe_url(manga_2)
          }
        },
        character: {
          character.id.to_s => {
            'id' => character.id,
            'text' => character.russian,
            'url' => character_url(character)
          }
        },
        person: {
          person.id.to_s => {
            'id' => person.id,
            'text' => person.russian,
            'url' => person_url(person)
          }
        },
        user_image: {
          user_image.id.to_s => {
            'id' => user_image.id,
            'url' => ImageUrlGenerator.instance.url(user_image, :original)
            # 'original_url' => user_image.image.url(:original),
            # 'preview_url' => user_image.image.url(:preview),
            # 'width' => user_image.width,
            # 'height' => user_image.height
          }
        },
        user: {
          user.id.to_s => {
            'id' => user.id,
            'nickname' => user.nickname,
            'avatar' => ImageUrlGenerator.instance.url(user, :x32),
            'url' => profile_url(user)
          }
        },
        comment: {
          comment.id.to_s => {
            'id' => comment.id,
            'author' => comment.user.nickname,
            'url' => comment_url(comment)
          }
        },
        message: {
          message.id.to_s => {
            'id' => message.id,
            'author' => message.from.nickname,
            'url' => profile_url(message.from)
          }
        },
        topic: {
          topic.id.to_s => {
            'id' => topic.id,
            'author' => topic.user.nickname,
            'url' => UrlGenerator.instance.topic_url(topic)
          }
        }
      )
    end

    context 'permissions' do
      let(:params) { { message: message.id.to_s } }
      let(:message) { create :message, from: user_2, to: user_2 }
      let(:user_2) { create :user, :user }

      it do
        expect(json).to eq(
          message: {
            message.id.to_s => nil
          }
        )
      end
    end

    context 'limit_per_request' do
      let(:limit_per_request) { 2 }

      it do
        expect(json).to eq(
          anime: {
            anime.id.to_s => {
              'id' => anime.id,
              'text' => anime.russian,
              'url' => anime_url(anime)
            }
          },
          manga: {
            manga_1.id.to_s => {
              'id' => manga_1.id,
              'text' => manga_1.russian,
              'url' => manga_url(manga_1)
            }
          },
          is_paginated: true
        )
      end
    end

    context 'non existing ids' do
      let(:params) do
        {
          anime: [anime.id, 123435546546].join(',')
        }
      end

      it do
        expect(json).to eq(
          anime: {
            anime.id.to_s => {
              'id' => anime.id,
              'text' => anime.russian,
              'url' => anime_url(anime)
            },
            '123435546546' => nil
          }
        )
      end
    end
  end
end
