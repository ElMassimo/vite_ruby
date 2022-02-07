<script setup>
defineProps({
  author: { type: String, default: null },
  href: { type: String, default: null },
})
</script>

<template>
  <div class="custom-block tip quote">
    <p>
      <slot/>
    </p>
    <p v-if="author" class="text-right text-sm mb-2 -mt-2 font-semibold">
      — <a :href="href" target="_blank" rel="noreferrer">{{ author }}</a>
    </p>
  </div>
</template>

<style scoped>
.custom-block {
  padding-left: 24px;
}

.custom-block:before {
  content: none!important;
}
</style>