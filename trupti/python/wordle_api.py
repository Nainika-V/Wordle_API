import requests 
import json 

session = requests.Session()

register_url = "https://wordle.we4shakthi.in/game/register"
create_url = "https://wordle.we4shakthi.in/game/create"
guess_url = "https://wordle.we4shakthi.in/game/guess"

register_data = {"mode": "wordle","name": "string"}
response = session.post(register_url , json = register_data)
print("rgister status : " , response.status_code)
register_json = response.json()
print("register response :" , register_json)
game_id = str(register_json.get("id"))

create_data = {"id": game_id,"overwrite": True}
response = session.post(create_url , json = create_data)
print("create status : " , response.status_code)
print("create response : " , response.json())

guess_data = {"guess" : "apple" , "id" : game_id}
response = session.post(guess_url, json = guess_data)
print("guess status : " , response.status_code)
print("guess response : " , response.json())
