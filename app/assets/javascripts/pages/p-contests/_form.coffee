ShikiEditor = require 'views/application/shiki_editor'

page_load 'contests_edit', ->
  $('.b-shiki_editor').each ->
    new ShikiEditor @

  $suggest = $('.edit.contest .member-suggest')

  $('.edit .proposing .hidden').removeClass 'hidden'

  # удаление элемента из опроса
  $('form').on 'click', 'input[type=checkbox]', ->
    update_members_count()

  $('form .proposing .take').on 'click', ->
    $(@).parent().hide()
    $('.member-suggest').trigger 'autocomplete:success', [{id: $(@).data('id'), name: $(@).data('text')}]
    $('.member-suggest').trigger 'blur'

  $('.member-suggest')
    .completable_variant()
    .on 'autocomplete:success', (e, entry) ->
      update_members_count()

  # пересчёт числа аниме
  update_members_count = ->
    members_count = $('#contest_member_ids_').next().find('input:checked').length

    console.log members_count
    $('.members_count').html(
      I18n.t('frontend.pages.p_contests.candidate', count: members_count)
    )

  update_members_count()
