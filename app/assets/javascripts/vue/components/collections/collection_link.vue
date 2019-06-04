<template lang="pug">
  .b-collection_item(
    :data-linked_id="link.linked_id"
    :data-group="link.group"
    :data-list_index='links.indexOf(link)'
  )
    .delete(
      @click="remove_link(link)"
    )
    .drag-handle(
      v-if="link.linked_id"
    )
    .b-input.new-record(
      v-if="!link.linked_id"
    )
      label
        //| {{ I18n.t(`frontend.collections.add.${collection.kind}`) }}
        input(
          type="text"
          :placeholder="I18n.t(`frontend.collections.autocomplete.${collection.kind}`)"
          :data-autocomplete='autocomplete_url'
        )
    .persisted(
      v-if="link.linked_id"
    )
      input(
        v-if="link.id"
        type="hidden"
        v-model="link.id"
        name="collection[links][][id]"
      )
      input(
        type="hidden"
        v-model="link.linked_id"
        v-if="link.linked_id"
        name="collection[links][][linked_id]"
      )
      input(
        type="hidden"
        v-model="link.group"
        name="collection[links][][group]"
      )
      a.b-link(
        :class="link.url ? 'bubbled' : ''"
        :href="link.url"
        data-predelay="600"
      ) {{ link.name }}
      .b-input
        //label(
        //  :for="'link_text_' + link.id"
        //) {{ I18n.t('activerecord.attributes.collection_link.text') }}
        textarea(
          :id="'link_text_' + link.id"
          :placeholder="I18n.t('activerecord.attributes.collection_link.text')"
          name="collection[links][][text]"
          rows="1"
          v-model="link.text"
          @focus.once="add_autosize"
        )
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import autosize from 'autosize'

function highlight(selector) {
  let $node = $(selector)

  if (!$node.is(':appeared')) {
    $.scrollTo($node, () => $node.yellowFade())
  } else {
    $node.yellowFade()
  }
}

export default {
  props: {
    link: Object,
    autocomplete_url: String
  },
  computed: {
    ...mapGetters([
      'collection',
      'links'
    ])
  },
  mounted() {
    this.$nextTick(() => {
      $(this.$el).process()

      if (!this.link.linked_id) {
        $('input', this.$el)
          .completable()
          .focus()
          .on('autocomplete:success', (e, { id, name, url }) => {
            this.assign({
              linked_id: parseInt(id),
              name,
              url
            })
          })
      }
    })
  },
  methods: {
    assign(changes) {
      this.fill_link({ link: this.link, changes: changes })

      this.$nextTick(() => {
        $(this.$el).process()

        highlight(
          '.b-collection_item' +
            `[data-linked_id='${this.link.linked_id}']` +
            `[data-group='${this.link.group}']`
        )
      })
    },
    add_autosize({target}) {
      autosize(target)
    },
    ...mapActions([
      'fill_link',
      'remove_link'
    ])
  }
}
</script>

<style scoped lang="sass">
textarea
  height: auto
  resize: none
  min-height: auto
</style>
