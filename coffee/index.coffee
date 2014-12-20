$ ->
#テキストの文字色に関する配列
  colorBackArr = [
    '#000000'
    'white'
    '#DD0000'
    '#FFFF77'
    '#00FF00'
    '#0000FF'
    '#FF44FF'
    '#FF6928'
  ]

#テキストに関する配列
  colorTextArr = [
    '黒'
    '白'
    '赤'
    '黄'
    '緑'
    '青'
    '紫'
    '橙'
  ]

#クイズの問題を入れておく配列
  colorQuiz = []

#カウントダウンに関する関数
  TIME = 60
  time = TIME
  timer = null

#画面のサイズを取得
  areaWidth = screen.width
  areaHeight = screen.height - (20 + 50 + 13) #
  areaSize = areaWidth + areaHeight
  $('.touch_area').css 'width': areaWidth, 'height' : areaHeight

  quizLevel = 1
  stageCount = 0
  quizCount = 0
  RANK = 7

#ゲームの初期化
  initGame = () ->
    quizLevel = 1
    stageCount = 0
    quizCount = 0
    time = TIME
    initGameView()


#ゲームの初期画面を表示する関数
  initGameView = () ->
    $('#header').css 'font-size' : """#{areaSize/50}px"""
    $('.quiz_area').append($("""<div id="quiz_0"class="quiz_color"></div>"""))
    $('.quiz_color').css 'width' : '100%', 'height' : '100%', 'font-size' : "#{areaSize/5}px"
    initQuiz()
    countStart()


#クイズ画面の初期化
  initQuiz = () ->
    stageCount++
    quizCount = 0
    $('#stage_count').text stageCount
    colorQuiz.length = 0
    changeLevel()
    $('.quiz_color').css 'opacity': '1.0'
    colorBackCount = colorBackArr.length-1
    colorTextCount = colorTextArr.length-1
    for i in [0...quizLevel]
      randomBack = _.random colorBackCount
      randomText = _.random colorTextCount
      colorQuiz.push randomText
      $("""#quiz_#{i}""").css('color': colorBackArr[randomBack]).text colorTextArr[randomText]

#記録の追加
  newRecord = localStorage.getItem 'record2'
  recordStorage = () ->
    record2 = localStorage.getItem 'record2'
    if stageCount > record2
      localStorage.setItem 'record2', stageCount
      newRecord = localStorage.getItem 'record2'
      reportScore()
#記録の書き換え
  addRecord = () ->
    yourRank = Math.round newRecord/RANK + 0.01
    $('#record .count').text """#{rankArray[yourRank]} """ if newRecord



#タッチした色が正解かどうかを判断する関数
  judgeAnswer = (value) ->
    colorId = Number(value.slice 6)
    quizValue = colorQuiz[quizCount]
    #if colorId == quizValue
    if colorId is quizValue
      $("""#quiz_#{quizCount}""").animate opacity:'0', 200
      quizCount++
      if quizCount == quizLevel
        time += 3
        timeFont()
        timeChangePlus()
        setTimeout ->
          initQuiz()
        , 300
    else
      time -= 3
      if time < 1
        time = 0
        $('#time_count').css('color', 'black').text time
        exitGame()
      $('#overlay_false').show().fadeOut 50
      timeFont()
      timeChangeMinus()



#ステージ数によりquizLevelを変更する関数
  changeLevel = () ->
    switch stageCount
      when 5
        quizLevel = 2
        changeQuizCount quizLevel
        $('.quiz_color').css 'width' : '50%', 'height' : '100%',  'font-size' : """#{areaSize/5}px"""
      when 10
        quizLevel = 4
        changeQuizCount quizLevel
        $('.quiz_color').css 'width' : '50%', 'height' : '50%', 'font-size' : """#{areaSize/8}px"""
      when 15
        quizLevel = 9
        changeQuizCount quizLevel
        $('.quiz_color').css 'width' : '33.333%', 'height' : '33.333%', 'font-size': """#{areaSize/12.5}px"""


#ステージ数に応じて問題数を変更する関数
  changeQuizCount = (value) ->
    $('.quiz_area').empty()
    for i in [0...value]
      $('.quiz_area').append($("""<div id=\"quiz_#{i}\"class=\"quiz_color\"></div>"""))


  $('.select_color').bind 'touchstart', ->
    $(@).addClass 'touch_active'
  $('.select_color').bind 'touchend', ->
    $(@).removeClass 'touch_active'
    selectColor = $(@).attr('id')
    judgeAnswer selectColor

#カウントダウンの関数
  countStart = () ->
    timer = setInterval countDown, 1000
  countDown = () ->
    time--
    timeFont()
    if time < 1
      time = 0
      $('#time_count').css('color', 'black').text time
      exitGame()

#時間の表示に関する関数
  timeFont = () ->
    if time <= 10
      $('#time_count').css('color', 'red').text time
    else
      $('#time_count').css('color', 'black').text time
    $('#time_count').text time

#時間のプラスやマイナスに関する関数
  timeChangePlus = () ->
    $('#time_change').text('+3')
    $('#time_change').css 'display': 'inline', 'color' : 'blue'
    setTimeout ->
      $('#time_change').addClass 'correct'
      setTimeout ->
        $('#time_change').removeClass 'correct'
        setTimeout ->
          $('#time_change').css 'display', 'none'
        , 1
      , 200
    , 100

  timeChangeMinus = () ->
    $('#time_change').text('-3')
    $('#time_change').css 'display': 'inline','color' : 'red'
    setTimeout ->
      $('#time_change').addClass 'wrong'
      setTimeout ->
        $('#time_change').removeClass 'wrong'
        setTimeout ->
          $('#time_change').css 'display', 'none'
        , 1
      , 200
    , 100

##########ゲームの終了に関する関数#################
  exitGame = () ->
    clearInterval timer
    $('#overlay_close').show()
    recordStorage()

#ランクに関する関数
  selectRank = () ->
    i = 0
    while (i*RANK < stageCount)
      i++
    $('#change_text_end').text rankArray[i]


#ゲームセンターに関する処理
  showLeaderboard = () ->
    GameCenter.prototype.showLeaderboard 'iroiroyayakoshize_rank'
  reportScore = () ->
    GameCenter.prototype.reportScore 'iroiroyayakoshize_rank', newRecord
    setTimeout 'showLeaderboard()', 2000



#########ゲームの画面切り替え#############
  addRecord()

  $('#start').bind 'touchend', ->
    $('#container_start').fadeOut('fast')
    $('#container_game').delay(400).fadeIn('slow')
    initGame()

  $('#ranking').bind 'touchend', ->
    showLeaderboard()

  $('#overlay_close #close_1').bind 'touchend', ->
    selectRank()
    addRecord()
    $('#countQuestion .count').text stageCount
    $('#overlay_close').fadeOut 'slow'
    $('#container_game').fadeOut('fast')
    $('#overlay_rank').delay(300).fadeIn 'slow'
    $('#container_end').delay(400).fadeIn('slow')

  $('#overlay_rank #close_2').bind 'touchend', ->
    $('#overlay_rank').fadeOut 'normal'

  $('#restart').bind 'touchend', ->
    $('#overlay_advertisement').show()
    $('#container_end').fadeOut 'fast'
    $('#container_start').delay(400).fadeIn 'slow'

  $('#overlay_advertisement #close_3').bind 'touchend', ->
    $('#overlay_advertisement').fadeOut 'slow'
