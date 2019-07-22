<template lang='pug'>
  #app
    p {{ `${message}` }}
</template>

<script>
export default {
  data: function () {
    return {
      message: 'Hello Vue!'
    };
  }
};
</script>

<style scoped lang='sass'>
@import "app/assets/stylesheets/globals/variables"

p
  color: $blue
  font-size: 2em
  text-align: center
</style>
