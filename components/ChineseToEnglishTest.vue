<script setup>
  import { ref, computed, inject } from 'vue'

  const testResults = inject('testResults')
  const questions = inject('questions')
  const pinyin = ref({})
  const english = ref({})
  const dictionary = ref({})
  const pinyinResults = ref({})
  const englishResults = ref({})

  function init() {
    pinyin.value = {}
    english.value = {}
    dictionary.value = {}
    pinyinResults.value = {}
    englishResults.value = {}
  }

  function submit() {
    axios
    .post('/submit_test', {
      chinese_to_pinyin: questions.value.map((word) => [word, pinyin.value[word] || '']),
      chinese_to_english: questions.value.map((word) => [word, english.value[word] || ''])
    })
    .then((response) => {
      testResults.value.push(response.data[0])
      testResults.value.push(response.data[2])
      localStorage.setItem('testResults', JSON.stringify(testResults.value))

      response.data[0][1].map((word) => pinyinResults.value[word] = 'correct')
      response.data[0][2].map((word) => pinyinResults.value[word] = 'incorrect')
      response.data[2][1].map((word) => englishResults.value[word] = 'correct')
      response.data[2][2].map((word) => englishResults.value[word] = 'incorrect')

      for (var i = 0; i < response.data[1].length; i++) {
        let word = response.data[1][i][0]
        let pinyin = response.data[1][i][1]
        let english = response.data[3][i][1]
        dictionary.value[word] = [pinyin, english]
      }
    })
    .catch((error) => console.log(error))
  }

  defineExpose({ init })
</script>

<style>
  table {
    border-collapse: collapse;
  }

  td {
    border: 1px solid #000;
    padding: 0.25rem;
    font-size: 2rem;
  }

  td.correct {
    background: #8f8;
    vertical-align: bottom;
  }

  td.incorrect {
    background: #f88;
  }

  span.hint {
    display: block;
  }
</style>

<template>
  <table>
    <thead>
      <tr>
        <td>Chinese</td>
        <td>Pinyin</td>
        <td>English</td>
      </tr>
    </thead>
    <tbody>
      <tr v-for="chinese in questions">
        <td>{{ chinese }}</td>
        <td :class="pinyinResults[chinese]">
          <span class="hint" v-if="pinyinResults[chinese] == 'incorrect'">
            {{ dictionary[chinese][0] }}
          </span>
          <input type="text" v-model="pinyin[chinese]" />
        </td>
        <td :class="englishResults[chinese]">
          <span class="hint" v-if="englishResults[chinese] == 'incorrect'">
            {{ dictionary[chinese][1].join(", ") }}
          </span>
          <input type="text" v-model="english[chinese]" />
        </td>
      </tr>
    </tbody>
  </table>
  <button @click="submit()">Submit</button>
</template>
