<script setup>
  import { ref, computed, provide } from 'vue'
  import Home from './Home.vue'
  import Test from './Test.vue'
  import Import from './Import.vue'
  import NotFound from './NotFound.vue'

  const routes = {
    '/': Home,
    '/test': Test,
    '/import': Import
  }

  const currentPath = ref(window.location.hash)

  window.addEventListener('hashchange', () => {
    currentPath.value = window.location.hash
  })

  const currentView = computed(() => {
    return routes[currentPath.value.slice(1) || '/'] || NotFound
  })

  const testResults = ref(JSON.parse(localStorage.getItem("testResults")) || [])
  provide('testResults', testResults)
</script>

<style>
  @import url('https://fonts.googleapis.com/css2?family=Open+Sans');

  * {
    font-family: 'Open Sans';
    font-size: 1rem;
  }

  #navbar {
    height: 4.25rem;
    line-height: 3.75rem;
    background-color: #1c9;
    color: #fff;
    padding: 0.25rem;
    font-size: 1.125rem;
  }

  #navbar * {
    font-size: 1.125rem;
  }

  #navbar a {
    color: #fff;
    text-decoration: none;
    font-weight: bold;
  }

  #navbar a:hover {
    text-decoration: underline;
  }

  #home {
    padding: 0 0 0 4.25rem;
    height: 3.75rem;
    background: url('./images/logo.png') no-repeat;
    display: inline-block;
  }

  #content {
    margin: 0.5rem 0.5rem;
  }
</style>

<template>
  <div id="navbar">
    <a href="#/"><span id="home">flashcards</span></a> |
    <a href="#/test">test</a> |
    <a href="#/import">import</a>
  </div>
  <div id="content">
    <component :is="currentView" />
  </div>
</template>
