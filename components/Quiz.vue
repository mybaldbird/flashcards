<script setup>
  import { ref, provide, nextTick } from 'vue'
  import { quizResults } from './utils/quizResults.js'
  import ChineseToEnglish from './quizzes/ChineseToEnglish.vue'

  const questions = ref([])
  provide('questions', questions)
  const quizComponent = ref(false)
  const quizComponentRef = ref()

  function chineseToEnglish() {
    axios
    .post('/quiz/chinese_to_english/build', { quiz_results: quizResults })
    .then((response) => {
      questions.value = response.data
      quizComponent.value = ChineseToEnglish
      nextTick(() => quizComponentRef.value.init())
    })
    .catch((error) => console.log(error))
  }
</script>

<style>
</style>

<template>
  <div id="lesson-select">
    <h3>Lesson Select</h3>
  </div>
  <div id="quiz-select">
    <h3>Quiz Select</h3>
    <button @click="chineseToEnglish()">Chinese to English</button>
    <button>English to Chinese</button>
    <button>Chinese Writing</button>
  </div>
  <component v-if="quizComponent" :is="quizComponent" ref="quizComponentRef" />
</template>
