import requests
import wordle_api
import wordle_bot

def play_game():
    words = wordle_bot.load_words("5words.txt")
    if not words:
        return
    remaining = words[:]

    with requests.Session() as session:
        game_id = wordle_api.setup_game_session(session)
    if not game_id:
        print("Failed to set up the game.")
    return

    for attempt in range(1, 7):
        print(f"\nAttempt {attempt} - Remaining words: {len(remaining)}")

        guess = wordle_bot.choose_word_to_guess(remaining, attempt)
        if not guess:
            print("No words left to guess.")
            break
        print(f"Guess: {guess}")

        feedback = wordle_api.get_feedback_from_api(session, game_id, guess)
        if not feedback:
            print("No feedback from API.")
            break
        print(f"Feedback: {feedback}")

        if feedback == "GGGGG":
            print("Yay! Solved!")
            break

        remaining = wordle_bot.filter_word_list(guess, feedback, remaining)
        if guess in remaining:
            remaining.remove(guess)
        else:
            print("Failed to solve within 6 attempts.")

if __name__ == "__main__":
    play_game()
