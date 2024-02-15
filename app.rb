require 'sinatra'
require 'sinatra/reloader'
require 'csv'

before do
  @data = JSON.parse(File.read('data.json'))
end

get '/' do
  send_file './index.html'
end

get '/components/*' do
  send_file File.join('./components', params['splat'][0])
end

get '/images/*' do
  send_file File.join('./images', params['splat'][0])
end

get '/dictionaries/chinese' do
  @data['chinese'].to_json
end

# import CSV of chinese words and store in the 'data.json' file
post '/import' do
  payload = JSON.parse(request.body.read)
  CSV.parse(payload['words']).map do |chinese, pinyin, english, lesson|
    @data['chinese'][chinese] ||= { 'english' => [] }
    @data['chinese'][chinese]['pinyin'] = pinyin
    @data['chinese'][chinese]['english'] |= [english]
    @data['chinese'][chinese]['lesson'] = lesson.to_i
  end

  File.write('data.json', @data.to_json)

  200
end

# build a chinese to english quiz
# use the previous quiz results (payload['quiz_results']) to weight which words get asked
post '/quiz/chinese_to_english/build' do
  payload = JSON.parse(request.body.read)

  scores = process_results(payload['quiz_results'], 'chinese')
  lowscores, highscores = partition_scores(scores)

  lowscores = (lowscores['chinese_to_pinyin'] + lowscores['chinese_to_english'])
    .sort_by(&:last)
    .map(&:first)
    .uniq
  highscores = (highscores['chinese_to_pinyin'] + highscores['chinese_to_english'])
    .sort_by(&:last)
    .map(&:first)
    .uniq - lowscores

  build_quiz(lowscores, highscores)
end

def process_results(results, dictionary)
  scores = {}
  @data[dictionary].keys.each do |word|
    scores[word] = {
      'chinese_to_pinyin' => { correct: 0, attempts: 0 },
      'chinese_to_english' => { correct: 0, attempts: 0 }
    }
  end

  results.each do |type, correct, incorrect|
    correct.each do |word|
      scores[word][type][:correct] += 1
      scores[word][type][:attempts] += 1
    end
    incorrect.each do |word|
      scores[word][type][:attempts] += 1
    end
  end

  scores
end

# 2 buckets:
#   lowscores = words that were correctly answered less than 80% of the time
#   highscores = the rest
# store how many times the word has been tested so that the less frequent ones are more likely to be
# selected
def partition_scores(scores)
  lowscores = Hash.new { |h, k| h[k] = [] }
  highscores = Hash.new { |h, k| h[k] = [] }

  scores.each do |word, scores_by_type|
    scores_by_type.each do |type, score|
      grade = (score[:attempts] == 0) ? 0.0 : score[:correct].to_f / score[:attempts]
      next lowscores[type] << [word, score[:attempts]] if grade < 0.8
      highscores[type] << [word, score[:attempts]]
    end
  end

  [lowscores, highscores]
end

# quiz should try to take 3 from the highscores bucket and 7 from the lowscores bucket
# if one of those buckets isn't big enough, fill in the rest from the other bucket
def build_quiz(lowscores, highscores)
  questions = []
  if highscores.size < 4
    questions = highscores
    questions << weighted_sample(lowscores) while questions.size < 10
  else
    if lowscores.size < 8
      questions = lowscores
    else
      questions << weighted_sample(lowscores) while questions.size < 7
    end
    questions << weighted_sample(highscores) while questions.size < 10
  end

  questions.shuffle.to_json
end

# squaring a random number will make the lower indexes more likely to be picked
def weighted_sample(array)
  r = rand
  array.delete_at((r * r * array.size).floor)
end

post '/quiz/chinese_to_english/submit' do
  payload = JSON.parse(request.body.read)

  response = []

  results = ['chinese_to_pinyin', [], []]
  dictionary = []
  payload['chinese_to_pinyin'].each do |word, pinyin|
    dictionary << [word, @data['chinese'][word]['pinyin']]
    next results[1] << word if @data['chinese'][word]['pinyin'] == pinyin
    results[2] << word
  end
  response << results
  response << dictionary

  results = ['chinese_to_english', [], []]
  dictionary = []
  payload['chinese_to_english'].each do |word, english|
    dictionary << [word, @data['chinese'][word]['english']]
    next results[1] << word if @data['chinese'][word]['english'].include? english
    results[2] << word
  end
  response << results
  response << dictionary

  response.to_json
end
