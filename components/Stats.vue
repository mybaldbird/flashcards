<script setup>
  import { ref } from 'vue'
  import { processedQuizResults } from './utils/quizResults.js'

  const quizTypeTitles = ref({
    'chinese_to_pinyin': 'Chinese to Pinyin',
    'chinese_to_english': 'Chinese to English'
  })
  const tableData = ref([])
  const currentQuizType = ref('chinese_to_pinyin')

  let results = processedQuizResults()

  axios
  .get('/dictionaries/chinese')
  .then((response) => {
    for (let chinese in response.data) {
      let entry = response.data[chinese]
      let row = {
        chinese: chinese,
        pinyin: entry.pinyin,
        english: entry.english,
        lesson: entry.lesson,
        quizzes: {}
      }

      for (let quizType in quizTypeTitles.value) {
        let result = results[quizType][chinese] || { correct: 0, attempts: 0 }
        let accuracy = ''
        if (result.attempts > 0) {
          accuracy = Math.round(result.correct / result.attempts * 10000) / 100
        }
        row.quizzes[quizType] = {
          accuracy: accuracy,
          attempts: result.attempts
        }
      }

      tableData.value.push(row)
    }

    switchQuiz('chinese_to_pinyin')
  })
  .catch((error) => console.log(error))

  function switchQuiz(quizType) {
    currentQuizType.value = quizType
    // TODO sorting
  }
</script>

<style>
  td {
    font-size: 1rem;
  }
</style>

<template>
  <button @click="switchQuiz('chinese_to_pinyin')">Chinese to Pinyin</button>
  <button @click="switchQuiz('chinese_to_english')">Chinese to English</button>
  <h3>Stats for {{ quizTypeTitles[currentQuizType] }}</h3>
  <table>
    <thead>
      <tr>
        <td>Chinese</td>
        <td>Pinyin</td>
        <td>English</td>
        <td>Lesson #</td>
        <td>Accuracy</td>
        <td>Attempts</td>
      </tr>
    </thead>
    <tbody>
      <tr v-for="row in tableData">
        <td>{{ row.chinese }}</td>
        <td>{{ row.pinyin }}</td>
        <td>
          <div v-for="english in row.english">{{ english }}</div>
        </td>
        <td>{{ row.lesson }}</td>
        <td>{{ row.quizzes[currentQuizType].accuracy }}</td>
        <td>{{ row.quizzes[currentQuizType].attempts }}</td>
      </tr>
    </tbody>
  </table>
</template>
