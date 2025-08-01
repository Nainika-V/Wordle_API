import scala.io.Source
import scala.io.StdIn.readLine
import scala.util.Random
import scala.annotation.tailrec

/**
 * A Scala 3 implementation of the Python Wordle solver.
 * * To run this code:
 * 1. Save it as `WordleSolver.scala`.
 * 2. Make sure you have a `5words.txt` file in the same directory.
 * 3. Run from your terminal using Scala CLI: `scala-cli run WordleSolver.scala`
 */
@main def main(): Unit = {
  val filepath = "5words.txt"
  try {
    val words = loadWords(filepath)
    println(s"✅ Loaded ${words.length} words.")
    gameLoop(1, words, humanFeedbackProvider)
  } catch {
    case e: java.io.FileNotFoundException =>
      println(s"❌ Error: Could not find the file at '$filepath'.")
    case e: Exception =>
      println(s"An unexpected error occurred: ${e.getMessage}")
  }
}

/**
 * The main game loop, implemented with tail recursion to prevent stack overflow.
 *
 * @param attempt The current attempt number (1-6).
 * @param remainingWords The list of words still considered possible.
 * @param feedbackProvider A function that takes a guess and returns feedback.
 */
@tailrec
def gameLoop(attempt: Int, remainingWords: List[String], feedbackProvider: String => String): Unit = {
  if (attempt > 6) {
    println("oops!")
    return
  }

  println(s"\n-- attempt : $attempt --")

  if (remainingWords.isEmpty) {
    println("I'm out of words! Did you provide the correct feedback?")
    return
  }

  // Choose a random word from the remaining possibilities
  val guessWord = remainingWords(Random.nextInt(remainingWords.length))
  println(s"My guess is: $guessWord")

  val feedback = feedbackProvider(guessWord)
  println(s"Feedback received: $feedback")

  if (feedback == "GGGGG") {
    println("Yay!")
  } else {
    // Note: The original Python code had a bug here, always filtering the full
    // word list. This version correctly filters the `remainingWords`.
    val newRemainingWords = dropImpossibles(guessWord, feedback, remainingWords)
    gameLoop(attempt + 1, newRemainingWords, feedbackProvider)
  }
}

/**
 * Reads a file line by line into a list of strings.
 */
def loadWords(filepath: String): List[String] = {
  val source = Source.fromFile(filepath)
  try {
    source.getLines().map(_.strip.toUpperCase).toList
  } finally {
    source.close()
  }
}

/**
 * Filters a list of words based on the feedback from a guess.
 *
 * NOTE: This is a direct translation of the provided Python logic. This logic is
 * simple and can be flawed in cases with duplicate letters. For example, if the
 * secret word is "SPEED" and the guess is "ARRAY", the feedback is "RYRRR". This
 * function would incorrectly eliminate "SPEED" because it contains an 'R'.
 * A more robust implementation would simulate the feedback for each word.
 */
def dropImpossibles(guessWord: String, feedback: String, remainingWords: List[String]): List[String] = {
  val feedbackPairs = guessWord.zip(feedback)

  val greens = feedbackPairs.zipWithIndex
    .filter { case ((_, f), _) => f == 'G' }
    .map { case ((char, _), index) => index -> char }
    .toMap

  val yellows = feedbackPairs
    .filter { case (_, f) => f == 'Y' }
    .map { case (char, _) => char }
    .toSet

  val reds = feedbackPairs
    .filter { case (_, f) => f == 'R' }
    .map { case (char, _) => char }
    .toSet

  remainingWords.filter { word =>
    val greenCondition = greens.forall { case (index, char) => word(index) == char }
    val yellowCondition = yellows.forall { char => word.contains(char) }
    val redCondition = reds.forall { char => !word.contains(char) }

    greenCondition && yellowCondition && redCondition
  }
}

/**
 * A function that takes a guess and prompts the human user for feedback.
 */
def humanFeedbackProvider(guessWord: String): String = {
  println(s"Feedback for '$guessWord' (R/Y/G): ")
  readLine().strip.toUpperCase
}

/**
 * A placeholder for a function that would get feedback from an API.
 */
def apiFeedbackProvider(guessWord: String): String = {
  // In a real application, you would make an HTTP request here.
  throw new NotImplementedError("API feedback provider is not implemented.")
}
