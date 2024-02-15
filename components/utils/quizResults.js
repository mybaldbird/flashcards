const quizResults = JSON.parse(localStorage.getItem('quizResults')) || []
module.exports.quizResults = quizResults

function pushQuizResult(result) {
  quizResults.push(result)
}
module.exports.pushQuizResult = pushQuizResult

function commitQuizResults() {
  localStorage.setItem('quizResults', JSON.stringify(quizResults))
}
module.exports.commitQuizResults = commitQuizResults

function processedQuizResults() {
  let results = {
    'chinese_to_pinyin': {},
    'chinese_to_english': {}
  }

  quizResults.forEach((quiz) => {
    quiz[1].forEach((correctWord) => {
      results[quiz[0]][correctWord] ||= { correct: 0, attempts: 0 }
      results[quiz[0]][correctWord].correct += 1
      results[quiz[0]][correctWord].attempts += 1
    })
    quiz[2].forEach((incorrectWord) => {
      results[quiz[0]][incorrectWord] ||= { correct: 0, attempts: 0 }
      results[quiz[0]][incorrectWord].attempts += 1
    })
  })

  return results
}
module.exports.processedQuizResults = processedQuizResults
