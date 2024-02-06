require 'sinatra'
require "sinatra/reloader"
require 'csv'

data = JSON.parse(File.read('data.json'))

get '/' do
  send_file './index.html'
end

get '/components/*' do
  send_file File.join('./components', params['splat'][0])
end

get '/images/*' do
  send_file File.join('./images', params['splat'][0])
end

# import CSV of chinese words and store in the 'data.json' file
post '/import' do
  payload = JSON.parse(request.body.read)
  CSV.parse(payload['words']).map do |chinese, pinyin, english, lesson|
    data[chinese] ||= { 'english' => [] }
    data[chinese]['pinyin'] = pinyin
    data[chinese]['english'] |= [english]
    data[chinese]['lesson'] = lesson.to_i
  end

  File.write('data.json', data.to_json)

  200
end

# build a certain type of test (indicated by payload['type'])
# use the previous test results (payload['test_results']) to weight the questions
post '/build_test' do
  payload = JSON.parse(request.body.read)

  empty_scores = {
    'chinese_to_pinyin' => [0, 0],
    'chinese_to_english' => [0, 0]
  }
  scores = data.keys.map { |chinese| [chinese, empty_scores.dup] }.to_h

  payload['test_results'].map do |type, correct, incorrect|
    correct.each do |chinese|
      scores[chinese][type][0] += 1
      scores[chinese][type][1] += 1
    end
    incorrect.each do |chinese|
      scores[chinese][type][1] += 1
    end
  end

  # 2 buckets:
  #   lowscores = chinese words that were correctly answered less than 80% of the time
  #   highscores = the rest
  # store how many times the word has been tested so that the less frequent ones are more likely to
  # be selected
  lowscores = Hash.new { |h, k| h[k] = [] }
  highscores = Hash.new { |h, k| h[k] = [] }

  scores.each do |chinese, scores_by_type|
    scores_by_type.each do |type, score|
      grade = (score[1] == 0) ? 0.0 : score[0].to_f / score[1]
      next lowscores[type] << [chinese, score[1]] if grade < 0.8
      highscores[type] << [chinese, score[1]]
    end
  end

  case payload['type']
  when 'chinese_to_english'
    lowscores = (lowscores['chinese_to_pinyin'] + lowscores['chinese_to_english'])
      .sort_by(&:last)
      .map(&:first)
      .uniq
    highscores = (highscores['chinese_to_pinyin'] + highscores['chinese_to_english'])
      .sort_by(&:last)
      .map(&:first)
      .uniq - lowscores
  when 'english_to_chinese'
  when 'chinese_writing'
  end

  # test should try to take 3 from the highscores bucket and 7 from the lowscores bucket
  # if one of those buckets isn't big enough, fill in the rest from the other bucket
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

post '/submit_test' do
  payload = JSON.parse(request.body.read)

  response = []

  if payload['chinese_to_pinyin']
    results = ['chinese_to_pinyin', [], []]
    dictionary = []
    payload['chinese_to_pinyin'].each do |word, pinyin|
      dictionary << [word, data[word]['pinyin']]
      next results[1] << word if data[word]['pinyin'] == pinyin
      results[2] << word
    end
    response << results
    response << dictionary
  end

  if payload['chinese_to_english']
    results = ['chinese_to_english', [], []]
    dictionary = []
    payload['chinese_to_english'].each do |word, english|
      dictionary << [word, data[word]['english']]
      next results[1] << word if data[word]['english'].include? english
      results[2] << word
    end
    response << results
    response << dictionary
  end

  response.to_json
end
