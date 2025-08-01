import random 

def load_words(filepath) -> list[str]:
    with open(filepath, 'r') as file:
        words = [line.strip() for line in file]
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

def human_feedback_provider(guess_word):
    return input(f"Feedback for '{guess_word}' (R/Y/G): ").strip().upper()

def api_feedback_provider(guess_word):
    response = call_feedback_api(guess_word) # type: ignore
    return response

def main(feedback_provider):
    filepath = "5words.txt"
    words = load_words(filepath)
    remaining_words = words[:]

    for attempt in range(1,7):
        print(f"\n-- attempt : {attempt} --")
        guess_word = random.choice(remaining_words)
        print(guess_word)
        feedback = feedback_provider(guess_word)
        print(feedback)
        if feedback == "GGGGG":
            print("Yay!")
            break
        remaining_words = dropImpossibles(guess_word, feedback, words)
    else:
        print("oops!")

main(human_feedback_provider)