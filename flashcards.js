const $ = (id) => document.getElementById(id);
let DATA = {};

function chineseToEnglishTest() {
  $("content").innerHTML = "";

  let high_scoring = [];
  let low_scoring = [];
  for (word in DATA.c) {
    let frequency = Math.min(DATA.c[word].p_t[1], DATA.c[word].e_t[1]);
    if (frequency == 0) {
      low_scoring.unshift([word, 0]);
      continue;
    }
    let score = Math.min(DATA.c[word].p_t[0] / DATA.c[word].p_t[1], DATA.c[word].e_t[0] / DATA.c[word].e_t[1]);
    if (score < 0.8) {
      let l = low_scoring.length;
      for (var i = 0; i < l; i++) {
        if (low_scoring[i][1] > frequency) {
          low_scoring = [...low_scoring.splice(0, i), [word, frequency], ...low_scoring];
          break;
        }
      }
      if (l == low_scoring.length) low_scoring.push([word, frequency]);
      continue;
    }
    let l = high_scoring.length;
    for (var i = 0; i < l; i++) {
      if (high_scoring[i][1] > frequency) {
        high_scoring = [...high_scoring.splice(0, i), [word, frequency], ...high_scoring];
        break;
      }
    }
    if (l == high_scoring.length) high_scoring.push([word, frequency]);
  }
  high_scoring = high_scoring.map((item) => { return item[0]; });
  low_scoring = low_scoring.map((item) => { return item[0]; });
  let test = { t: "c2e", q: [], p: 0, e: 0 };
  let questions = [];
  if (high_scoring.length < 4) {
    questions = high_scoring;
    var i = questions.length;
    while (i < 10) {
      pushRandomQuestion(questions, low_scoring);
      i++;
    }
  } else if (low_scoring.length < 8) {
    questions = low_scoring;
    var i = questions.length;
    while (i < 10) {
      pushRandomQuestion(questions, high_scoring);
      i++;
    }
  } else {
    var i = 0;
    while (i < 3) {
      pushRandomQuestion(high_scoring);
      i++;
    }
    while (i < 10) {
      pushRandomQuestion(low_scoring);
      i++;
    }
  }

  let chinese_to_english_test_template = $("chinese-to-english-test-template").content.cloneNode(true);

  const question = $("chinese-to-english-test-question-template");
  questions.map((word) => {
    let new_question = question.content.cloneNode(true);
    new_question.querySelector("td.chinese").innerText = word;
    chinese_to_english_test_template.querySelector("tbody").appendChild(new_question);
  });

  $("content").appendChild(chinese_to_english_test_template);
  $("btn-test-submit").onclick = submitChineseToEnglishTest;
}

function pushRandomQuestion(target, source) {
  var r = Math.random();
  r = r * r * r;
  target.push(source.splice(Math.floor(r * source.length), 1)[0])
}

function submitChineseToEnglishTest() {
  let pinyin_correct = 0;
  let pinyin_total = 0;
  let english_correct = 0;
  let english_total = 0;
  $("content").querySelectorAll("tbody tr").forEach((row) => {
    let word = row.querySelector("td.chinese").innerText;

    let pinyin_td = row.querySelector("td.pinyin");
    let pinyin_answer = pinyin_td.querySelector("input").value;
    if (DATA.c[word].p == pinyin_answer) {
      pinyin_td.classList.add("correct");
      pinyin_correct++;
    } else {
      pinyin_td.classList.add("incorrect");
    }
    pinyin_total++;

    let english_td = row.querySelector("td.english");
    let english_answer = english_td.querySelector("input").value.toLowerCase();
    let correct_english_answers = DATA.c[word].e.map((answer) => { return answer.toLowerCase(); });
    if (correct_english_answers.includes(english_answer)) {
      english_td.classList.add("correct");
      english_correct++;
    } else {
      english_td.classList.add("incorrect");
    }
    english_total++;
  });

  let scores = $("content").querySelector("div.scores")
  let pinyin_score = document.createElement("div");
  pinyin_score.innerText = `${pinyin_correct}/${pinyin_total} correct pinyin answers`
  let english_score = document.createElement("div");
  english_score.innerText = `${english_correct}/${english_total} correct english answers`
  scores.appendChild(pinyin_score);
  scores.appendChild(english_score);
}

function englishToChineseTest() {
  console.log("englishToChineseTest");
}

function characterTest() {
  console.log("characterTest");
}

function stats() {
  console.log("stats");
}

function wordList() {
  $("content").innerHTML = "";

  let word_list_template = $("word-list-template").content.cloneNode(true);

  const row = $("word-row-template");
  for (const word in DATA.c) {
    let new_row = row.content.cloneNode(true);
    new_row.querySelector("td.chinese").innerText = word;
    new_row.querySelector("td.pinyin").innerText = DATA.c[word].p;
    new_row.querySelector("td.english").innerText = DATA.c[word].e.join(", ");
    word_list_template.querySelector("tbody").appendChild(new_row);
  }

  $("content").appendChild(word_list_template);
}

function importWords() {
  $("content").innerHTML = "";

  let import_words_template = $("import-words-template").content.cloneNode(true);
  $("content").appendChild(import_words_template);
  $("btn-import-text").onclick = importText;
}

function importText() {
  $("import-text").disabled = true;
  $("btn-import-text").disabled = true;

  let text = $("import-text").value;
  text.split("\n").map((line) => {
    let [chinese, pinyin, english] = line.split(",");
    DATA.c[chinese] ||= { p: pinyin, e: [], p_t: [0, 0], e_t: [0, 0], c_t: [0, 0], e2c_t: [0, 0], e2p_t: [0, 0] };
    if (!(english in DATA.c[chinese].e)) DATA.c[chinese].e.push(english);

    DATA.e[english] ||= [];
    if (!(chinese in DATA.e[english])) DATA.e[english].push(chinese);
  });
  localStorage.setItem("data", JSON.stringify(DATA));

  $("import-text").value = "";
  $("import-text").disabled = false;
  $("btn-import-text").disabled = false;
}

(() => {
  DATA = JSON.parse(localStorage.getItem("data")) || { c: {}, e: {}, t: [] };
  $("btn-chinese-to-english-test").onclick = chineseToEnglishTest;
  $("btn-english-to-chinese-test").onclick = englishToChineseTest;
  $("btn-character-test").onclick = characterTest;
  $("btn-stats").onclick = stats;
  $("btn-word-list").onclick = wordList;
  $("btn-import-words").onclick = importWords;
})();
