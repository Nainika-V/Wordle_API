import random
import requests
URL = "https://wordle.we4shakthi.in/game/"
REGISTER_URL = URL +  "register"
CREATE_URL = URL + "create"
GUESS_URL = URL + "guess"

def load_words(filepath: str) -> list[str]:
    with open(filepath, 'r') as file:
        words = [line.strip().upper() for line in file]
    return words

def dropImpossibles(guess_word, feedback, remaining_words) -> list[str]:
    greens = {i: guess_word[i] for i, f in enumerate(feedback) if f == 'G'}
    yellows = {guess_word[i] for i, f in enumerate(feedback) if f == 'Y'}
    reds = {guess_word[i] for i, f in enumerate(feedback) if f == 'R'}
    possible_words = [
        word for word in remaining_words
        if all(word[i] == char for i, char in greens.items()) and
           all(char in word for char in yellows) and
           all(char not in word for char in reds)
    ]
    return possible_words


def register_and_create_game(session: requests.Session) -> str | None:

    try:
        register_data = {"mode": "wordle", "name": "GeminiBot"}
        reg_response = session.post(REGISTER_URL, json=register_data, timeout=10)
        reg_response.raise_for_status()
        game_id = str(reg_response.json().get("id"))

        create_data = {"id": game_id, "overwrite": True}
        create_response = session.post(CREATE_URL, json=create_data, timeout=10)
        create_response.raise_for_status()
        
        # print(f"Game created with ID: {game_id}")
        return game_id
    except requests.exceptions.RequestException as e:
        print(f"Error setting up game: {e}")
        return None

def make_guess(session: requests.Session, game_id: str, guess_word: str) -> str | None:
    try:
        guess_data = {"guess": guess_word, "id": game_id}
        response = session.post(GUESS_URL, json=guess_data, timeout=10)
        response.raise_for_status()
        guess_json = response.json()
        feedback_list = guess_json.get("feedback", [])
        return "".join(feedback_list)
    except requests.exceptions.RequestException as e:
        print(f"Error making guess: {e}")
        return None
    
def main():
    all_words = load_words("5words.txt")
    remaining_words = all_words[:]

    with requests.Session() as session:
        game_id = register_and_create_game(session)
        if not game_id:
            return
        print()
        for attempt in range(1, 6):
            if not remaining_words:
                print("No possible words left! The bot is stumped.")
                break
            guess_word = random.choice(remaining_words)
            feedback = make_guess(session, game_id, guess_word)
            if not feedback:
                print("Could not retrieve feedback. Exiting.")
                break
            print(f"-- Attempt {attempt} --")
            print(f"Guess    : {guess_word}")
            print(f"feedback : {feedback}")
            print()

            if feedback == "GGGGG":
                print("Yay! The bot solved the Wordle! 🎉")
                break
            
            remaining_words = dropImpossibles(guess_word, feedback, remaining_words)
        else:
            print("Oops! The bot couldn't solve the Wordle in 6 attempts. 😢")

if __name__ == "__main__":
    main()