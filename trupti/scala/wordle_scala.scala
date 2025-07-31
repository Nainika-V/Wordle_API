//> using dep "com.lihaoyi::requests:0.9.0"
//> using dep "com.lihaoyi::ujson:4.2.1"

import requests._
import ujson._ 
import scala.util.Random 
import scala.io.Source 

var words: List[String] = Nil 
var possibleWords: List[String] = Nil 
var guessWord: String = ""
var feedback: String = ""
var WIN = "GGGGG"

var Url = "https://wordle.we4shakthi.in/game/"

var sessionCookie: String = ""
var gameId: String = ""

def LoadWords(filePath : String) : List[String] = 
  Source.fromFile(filePath).getLines().toList

def registerAndCreateGame(): Unit =
  val regPayload = Obj("mode" -> "wordle", "name" -> "Trupti")
  val regResponse = requests.post((Url+"register"), data = regPayload)
  sessionCookie = regResponse.cookies("session").getValue
  gameId = ujson.read(regResponse.text())("id").str

  val createPayload = Obj("id" -> gameId, "overwrite" -> true)
  val createResponse = requests.post((Url+"create"), data = createPayload, cookieValues = Map("session" -> sessionCookie))
  if (createResponse.cookies.contains("session")) {
    sessionCookie = createResponse.cookies("session").getValue
  }
  println("Game registered and created.")
  println("")

def processFeedback() : Unit = 
  val greens = Array.fill(5)(' ')
  val ambers = new StringBuilder()
  val blacks = new StringBuilder()

  for (i <- 0 until 5){
    feedback(i) match
      case 'G' => greens(i) = guessWord(i)
      case 'Y' => ambers += guessWord(i)
      case 'R' => blacks += guessWord(i)
      case _   => println(s"Invalid feedback character at $i")
  }

  def dropBlacks(word: String) : Boolean = 
    blacks.forall(ch => !word.contains(ch))

  def pickGreens(word: String) : Boolean = 
    (0 until 5).forall(i => greens(i) == ' ' || word(i) == greens(i))

  def pickAmbers(word: String) : Boolean = 
    ambers.forall(ch => word.contains(ch))
  
  possibleWords = possibleWords.filter(word =>
    dropBlacks(word) && pickGreens(word) && pickAmbers(word)
  )
  println(s"Remaining possible words : ${possibleWords.length}")

@main def runApp(): Unit = 
  val path = "5words.txt"
  words = LoadWords(path)
  possibleWords = words

  registerAndCreateGame()
  
  var guessedCorrectly = false 
  var attempts = 0 

  while (attempts < 6 && !guessedCorrectly && possibleWords.nonEmpty){
    guessWord = possibleWords(Random.nextInt(possibleWords.length)) 
    val guessPayload = Obj("guess" -> guessWord, "id" -> gameId)
    val guessResponse = requests.post((Url+"guess"), data = guessPayload, cookieValues = Map("session" -> sessionCookie))
    val guessJson = ujson.read(guessResponse.text())
    feedback = guessJson("feedback").str
    println(s"Attempt ${attempts+1}: My guess: $guessWord | Feedback: $feedback")

    if feedback == WIN then
      println("YAY! I won!")
      guessedCorrectly = true
    else
      processFeedback()
      attempts += 1
      println("")

  }
  if (!guessedCorrectly) then 
    println("Oops!")
