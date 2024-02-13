<script setup>
  import { ref, provide, inject, nextTick } from 'vue'
  import ChineseToEnglishTest from './ChineseToEnglishTest.vue'

  const testResults = inject('testResults')
  const questions = ref([])
  provide('questions', questions)
  const testQuestions = ref(false)
  const testQuestionsRef = ref()

  function chineseToEnglish() {
    axios
    .post('/build_test', { type: 'chinese_to_english', test_results: testResults.value })
    .then((response) => {
      questions.value = response.data
      testQuestions.value = ChineseToEnglishTest
      nextTick(() => testQuestionsRef.value.init())
    })
    .catch((error) => console.log(error))
  }
</script>

<style>
</style>

<template>
  <div id="test-select">
    <h3>Test Select</h3>
    <button @click="chineseToEnglish()">Chinese to English</button>
    <button>English to Chinese</button>
    <button>Chinese Writing</button>
  </div>
  <div id="lesson-select">
    <h3>Lesson Select</h3>
  </div>
  <component v-if="testQuestions" :is="testQuestions" ref="testQuestionsRef" />
</template>
