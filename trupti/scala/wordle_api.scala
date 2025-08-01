// //> using dep "com.lihaoyi::requests:0.9.0"
// //> using dep "com.lihaoyi::ujson:4.2.1"

// import requests.Session
// import ujson.Obj

// var sessionCookie: String = ""
// var gameId: String = ""
// val baseUrl = "https://wordle.we4shakthi.in/game/"

// @main def main(): Unit = 
//   registerAndCreateGame()
//   makeGuess("APPLE")

// def registerAndCreateGame(): Unit = 
//   println("--- 1. Registering and Creating Game ---")
//   try {
//     val regPayload = Obj("mode" -> "wordle", "name" -> "Trupti_Scala_Bot")
//     val regResponse = requests.post(s"${baseUrl}register", data = regPayload)
//     println(s"Register Status: ${regResponse.statusCode}")

//     sessionCookie = regResponse.cookies("session").getValue
//     gameId = ujson.read(regResponse.text())("id").str
//     println(s"Game ID: $gameId")

//     val createPayload = Obj("id" -> gameId, "overwrite" -> true)
//     val createResponse = requests.post(
//       s"${baseUrl}create",
//       data = createPayload,
//       cookieValues = Map("session" -> sessionCookie)
//     )
//     println(s"Create Status: ${createResponse.statusCode}")

//     // The session cookie might be updated upon game creation.
//     if (createResponse.cookies.contains("session")) {
//       sessionCookie = createResponse.cookies("session").getValue
//     }
//     println("Game registered and created successfully.")
//   } catch {
//     case e: Exception =>
//       println(s"An error occurred during setup: ${e.getMessage}")
//   }


// def makeGuess(guessWord: String): Unit = 
//   println(s"\n--- 2. Making a Guess ---")
//   if (gameId.isEmpty || sessionCookie.isEmpty) {
//     println("Cannot make a guess. Please register a game first.")
//     return
//   }

//   println(s"Guessing word: $guessWord")
//   try {
//     val guessPayload = Obj("guess" -> guessWord.toLowerCase, "id" -> gameId)
//     val guessResponse = requests.post(
//       s"${baseUrl}guess",
//       data = guessPayload,
//       cookieValues = Map("session" -> sessionCookie)
//     )

//     println(s"Guess Status: ${guessResponse.statusCode}")
//     val guessJson = ujson.read(guessResponse.text())
//     println(s"API Response: $guessJson")
//   } catch {
//     case e: Exception =>
//       println(s"An error occurred during the guess: ${e.getMessage}")
//   }
