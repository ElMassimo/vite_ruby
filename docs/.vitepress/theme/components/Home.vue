<script setup lang="ts">
import { useData } from 'vitepress'

const { frontmatter } = useData()
</script>

<template>
  <section id="hero" class="flex flex-col items-center">
    <img class="logo" src="/logo.svg" height="220" alt="Vite Ruby Logo by Maximo Mussini"/>
    <h1 class="tagline font-semibold">
      Vite Ruby
    </h1>
    <p class="description text-lg md:text-2xl">
      Bringing joy to your frontend experience.
    </p>
    <p class="actions">
      <a class="get-started" href="/guide/introduction.html">
        Get Started
        <svg
          class="icon"
          xmlns="http://www.w3.org/2000/svg"
          width="10"
          height="10"
          viewBox="0 0 24 24"
        >
          <path
            d="M13.025 1l-2.847 2.828 6.176 6.176h-16.354v3.992h16.354l-6.176 6.176 2.847 2.828 10.975-11z"
          />
        </svg>
      </a>
      <a class="setup" href="/guide/index.html">Install</a>
    </p>
  </section>

  <section id="highlights">
    <a class="highlight" v-for="feature in frontmatter.features" :href="feature.link">
      <h2 class="font-semibold">{{ feature.title }}</h2>
      <p v-html="feature.details"/>
    </a>
  </section>
</template>

<style scoped>
h1, h2, p, a {
  transition: color 0.5s, background-color 0.5s;
}

#hero {
  padding: 96px 32px;
  text-align: center;
}

.logo {
  height: 220px;
}

.tagline {
  background: -webkit-linear-gradient(317deg, #000 25%, #000);
  font-size: 45px;
  line-height: 1.25;
  letter-spacing: -1.5px;
  margin-top: 2rem;
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

html:not(.dark) .accent,
.dark .tagline {
  background-image: -webkit-linear-gradient(317deg, var(--vt-c-yellow) 25%, var(--vt-c-brand) 75%);
}

.description {
  line-height: 1;
  color: var(--vt-c-text-2);
  margin: 10px 0px 60px 0px;
}

.actions a {
  font-size: 16px;
  display: inline-block;
  background-color: var(--vt-c-bg-mute);
  padding: 8px 18px;
  font-weight: 500;
  border-radius: 8px;
}

.actions .get-started {
  font-weight: 600;
  background-color: var(--vt-c-brand);
  color: #fff;
  margin-right: 18px;
}

.actions .icon {
  display: inline;
  position: relative;
  top: -1px;
  margin-left: 2px;
  fill: currentColor;
  transition: transform 0.2s;
}

.dark .actions .get-started {
  color: var(--vt-c-text-1);
}

.actions .get-started:hover .icon {
  transform: translateX(2px);
}

.actions .get-started:hover {
  background-color: var(--vt-c-brand-light);
}

.actions .setup {
  color: var(--vt-c-text-code);
}

.actions .setup:hover {
  background-color: var(--vt-c-gray-light-4);
  transition-duration: 0.2s;
}

.dark .actions .setup:hover {
  background-color: var(--vt-c-gray-dark-3);
}

#highlights {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  max-width: 972px;
  margin: 0px auto;
  padding: 0 32px 72px;
  color: var(--vt-c-text-2);
}

.highlight {
  padding: 28px 36px;
  border-radius: 8px;
  flex: 0 32%; /* default 3 column */
  font-size: 14px;
  font-weight: 500;
}

@media (max-width: 768px) {
  #highlights {
    flex-direction: column;
    gap: 20px;
  }

  .highlight {
    text-align: center;
  }
}

.highlight h2 {
  font-size: 20px;
  letter-spacing: -0.4px;
  color: var(--vt-c-text-1);
  margin-bottom: 0.75em;
}

.highlight p {
  font-size: 15px;
}
</style>
