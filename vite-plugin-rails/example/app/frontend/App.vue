<script lang="ts">
import { defineComponent } from 'vue'
import HelloWorld from '~/components/HelloWorld.vue'

export default defineComponent({
  name: 'App',
  components: {
    HelloWorld,
  },
})
</script>

<template>
  <img alt="Vue logo" src="./images/logo.svg">
  <HelloWorld class="strange" msg="Hello Vue 3 + Vite"/>
</template>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
}
</style>
