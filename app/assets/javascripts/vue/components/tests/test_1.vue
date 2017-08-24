<template lang="pug">
  form
    div you wrote: {{input_data.value != '' ? input_data.value : 'nothing'}}
    c_input(
      :input_data="input_data"
    )
    button Отправить
</template>

<script>
import c_input from './test_2'
export default {
  components: { c_input },
  data() {
    return {
      input_data: {
        name: Math.random().toString(36).replace(/[^a-z]+/g, '').substr(0, 5),
        append: '',
        value: '',
        placeholder: '',
        error: 'zz'
      }
    }
  }
}
</script>
