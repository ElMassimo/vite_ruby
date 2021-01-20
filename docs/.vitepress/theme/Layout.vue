<script>
import Theme from 'vitepress/theme'
import AlgoliaSearchBox from './components/AlgoliaSearchBox.vue'

export default {
  name: 'Layout',

  components: {
    ParentLayout: Theme.Layout,
    AlgoliaSearchBox,
  },
}
</script>

<template>
  <ParentLayout>
    <template #navbar-search>
      <AlgoliaSearchBox :options="$site.themeConfig.algolia"/>
    </template>
    <template #page-top/>
    <template #page-bottom/>
  </ParentLayout>
</template>

<style>
form {
  margin-block-end: 0;
}
</style>
