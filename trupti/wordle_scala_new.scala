//> using dep "com.lihaoyi::requests:0.9.0"
//> using dep "com.lihaoyi::ujson:4.2.1"

import requests._ 
import ujson._ 

// creating session 
val sess = requests.Session()

//endpoint urls  

// register a game
def register(sess : requests.Session): (String, Value) = 
    val register_url = "https://wordle.we4shakthi.in/game/register"
    val register_data = Obj("mode" -> "wordle" , "name" -> "Trupti")
    val response =  sess.post(register_url, data = register_data)
    val json = ujson.read(response.text())
    val game_id = json("id").str
    println(s"register Status : ${response.statusCode}")
    println(s"Register Response : $json")
    (game_id, json)

// creating a game 
def create(sess : requests.Session, game_id : String): Unit = 
    val create_url = "https://wordle.we4shakthi.in/game/create"
    val create_data = Obj("id" -> game_id, "overwrite" -> true)
    val response = sess.post(create_url, data = create_data)
    val json = ujson.read(response.text())
    println(s"Create Status: ${response.statusCode}")
    println(s"Create Response: $json")

// guessing 
def guess(sess : requests.Session , game_id : String) : Unit = 
    for (i <- 1 to 5) do 
        val guess_url = "https://wordle.we4shakthi.in/game/guess"
        val guess_data = Obj("guess" -> "frock" , "id" -> game_id)
        val response = sess.post(guess_url, data = guess_data)
        val json = ujson.read(response.text())
        println(s"Guess Status: ${response.statusCode}")
        println(s"Guess Response: $json")

@main def main(): Unit = 
    val (id , json) = register(sess)
    println(s"Game Registerd.")
    println(s"Gmae Id : $id")
    create(sess, id)
    guess(sess, id)