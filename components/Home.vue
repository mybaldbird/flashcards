<script setup>
  import { ref } from 'vue'
  import { processedQuizResults } from './utils/quizResults.js'

  const summarizedResults = ref({})
  const quizTypeTitles = ref({
    'chinese_to_pinyin': 'Chinese to Pinyin',
    'chinese_to_english': 'Chinese to English'
  })

  let results = processedQuizResults()

  for (let quizType in results) {
    summarizedResults.value[quizType] = { best: [], worst: [] }
    let scores = []
    for (let word in results[quizType]) {
      scores.push([
        word,
        results[quizType][word].correct / results[quizType][word].attempts,
        results[quizType][word].attempts
      ])
    }
    scores.sort((a, b) => (b[1] - a[1] == 0) ? b[2] - a[2] : b[1] - a[1])
    scores.slice(0, 5).forEach((score) => {
      summarizedResults.value[quizType].best.push({
        word: score[0], score: score[1], attempts: score[2]
      })
    })
    scores.sort((a, b) => (a[1] - b[1] == 0) ? b[2] - a[2] : a[1] - b[1])
    scores.slice(0, 5).forEach((score) => {
      summarizedResults.value[quizType].worst.push({
        word: score[0], score: score[1], attempts: score[2]
      })
    })
  }
</script>

<style>
  td {
    font-size: 1rem;
  }
</style>

<template>
  <div v-for="(title, quizType) in quizTypeTitles">
    <h3>Best {{ title }}</h3>
    <table>
      <thead>
        <tr>
          <td>Word</td>
          <td>Accuracy</td>
          <td>Attempts</td>
        </tr>
      </thead>
      <tbody>
        <tr v-for="stats in summarizedResults[quizType].best"
            v-if="summarizedResults[quizType].best.length">
          <td>{{ stats.word }}</td>
          <td>{{ Math.round(stats.score * 10000) / 100 }}</td>
          <td>{{ stats.attempts }}</td>
        </tr>
        <tr v-else>
          <td colspan="3">No results</td>
        </tr>
      </tbody>
    </table>
    <h3>Worst {{ title }}</h3>
    <table>
      <thead>
        <tr>
          <td>Word</td>
          <td>Accuracy</td>
          <td>Attempts</td>
        </tr>
      </thead>
      <tbody>
        <tr v-for="stats in summarizedResults[quizType].worst"
            v-if="summarizedResults[quizType].worst.length">
          <td>{{ stats.word }}</td>
          <td>{{ Math.round(stats.score * 10000) / 100 }}</td>
          <td>{{ stats.attempts }}</td>
        </tr>
        <tr v-else>
          <td colspan="3">No results</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
