<script>
import { defineComponent } from 'vue'
import HelloWorld from '~/components/HelloWorld.vue'

export default defineComponent({
  name: 'App',
  components: {
    HelloWorld
  }
})
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>

<template>
  <img alt="Vue logo" src="../assets/logo.png" />
  <HelloWorld class="strange" msg="Hello Vue 3 + Vite" />
</template>
