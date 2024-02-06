<script setup>
  import { ref } from 'vue'

  const words = ref('')

  function importWords() {
    axios
    .post('/import', { words: words.value })
    .then((response) => console.log(response.data))
    .catch((error) => console.log(error))
  }
</script>

<style>
  textarea {
    display: block;
    width: 50rem;
    height: 35rem;
    padding: 0.5rem;
  }
</style>

<template>
  <textarea v-model="words"></textarea>
  <button @click="importWords()">Import</button>
</template>
