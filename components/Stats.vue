<script setup>
  import { ref, inject } from 'vue'

  const testResults = inject('testResults')
  const testTypeTitles = ref({
    'chinese_to_pinyin': 'Chinese to Pinyin',
    'chinese_to_english': 'Chinese to English'
  })
  const tableData = ref([])
  const currentTestType = ref('chinese_to_pinyin')

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

  axios
  .get('/dictionary')
  .then((response) => {
    for (let chinese in response.data) {
      let entry = response.data[chinese]
      let row = {
        chinese: chinese,
        pinyin: entry.pinyin,
        english: entry.english,
        lesson: entry.lesson,
        tests: {}
      }

      for (let testType in testTypeTitles.value) {
        let result = processedResults[testType][chinese] || { correct: 0, attempts: 0 }
        let accuracy = ''
        if (result.attempts > 0) {
          accuracy = Math.round(result.correct / result.attempts * 10000) / 100
        }
        row.tests[testType] = {
          accuracy: accuracy,
          attempts: result.attempts
        }
      }

      tableData.value.push(row)
    }

    switchTest('chinese_to_pinyin')
  })
  .catch((error) => console.log(error))

  function switchTest(testType) {
    currentTestType.value = testType
    // TODO sorting
  }
</script>

<style>
  td {
    font-size: 1rem;
  }
</style>

<template>
  <button @click="switchTest('chinese_to_pinyin')">Chinese to Pinyin</button>
  <button @click="switchTest('chinese_to_english')">Chinese to English</button>
  <h3>Stats for {{ testTypeTitles[currentTestType] }}</h3>
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
        <td>{{ row.tests[currentTestType].accuracy }}</td>
        <td>{{ row.tests[currentTestType].attempts }}</td>
      </tr>
    </tbody>
  </table>
</template>
