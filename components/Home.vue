<script setup>
  import { ref, inject } from 'vue'

  const testResults = inject('testResults')
  const summarizedResults = ref({})
  const testTypeTitles = ref({
    'chinese_to_pinyin': 'Chinese to Pinyin',
    'chinese_to_english': 'Chinese to English'
  })

  let processedResults = {}
  for (let testType in testTypeTitles.value) { processedResults[testType] = {} }

  testResults.value.forEach((test) => {
    test[1].forEach((correctWord) => {
      processedResults[test[0]][correctWord] ||= { correct: 0, attempts: 0 }
      processedResults[test[0]][correctWord].correct += 1
      processedResults[test[0]][correctWord].attempts += 1
    })
    test[2].forEach((incorrectWord) => {
      processedResults[test[0]][incorrectWord] ||= { correct: 0, attempts: 0 }
      processedResults[test[0]][incorrectWord].attempts += 1
    })
  })

  for (let testType in processedResults) {
    summarizedResults.value[testType] = { best: [], worst: [] }
    let scores = []
    for (let word in processedResults[testType]) {
      scores.push([
        word,
        processedResults[testType][word].correct / processedResults[testType][word].attempts,
        processedResults[testType][word].attempts
      ])
    }
    scores.sort((a, b) => (b[1] - a[1] == 0) ? b[2] - a[2] : b[1] - a[1])
    scores.slice(0, 5).forEach((score) => {
      summarizedResults.value[testType].best.push({
        word: score[0], score: score[1], attempts: score[2]
      })
    })
    scores.sort((a, b) => (a[1] - b[1] == 0) ? b[2] - a[2] : a[1] - b[1])
    scores.slice(0, 5).forEach((score) => {
      summarizedResults.value[testType].worst.push({
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
  <div v-for="(title, testType) in testTypeTitles">
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
        <tr v-for="stats in summarizedResults[testType].best"
            v-if="summarizedResults[testType].best.length">
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
        <tr v-for="stats in summarizedResults[testType].worst"
            v-if="summarizedResults[testType].worst.length">
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
