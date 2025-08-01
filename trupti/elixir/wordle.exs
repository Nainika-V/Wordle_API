defmodule Wordle do
  Code.require_file("wordle_httpoison.exs")

  def run do
    all_words = load_words("5words.txt")

    with {:ok, cookie, user_id} <- API.register(),
         {:ok, cookie, game_id} <- API.create(cookie, user_id) do
      game_loop(all_words, cookie, game_id, 1)
    else
      {:error, reason} -> IO.puts("Setup failed: #{reason}")
    end
  end

  def load_words(filepath) do
    filepath
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&(&1 |> String.trim() |> String.upcase()))
  end

  defp game_loop(_words, _cookie, _game_id, attempt) when attempt > 5,
    do: IO.puts("Bot couldn't solve in 5 attempts.")

  defp game_loop(words, cookie, game_id, attempt) do
    IO.puts("\n--- Attempt #{attempt} ---")
    # IO.puts("Possible words remaining: #{length(words)}")

    if Enum.empty?(words) do
      IO.puts("❌ No possible words left! Check the logic or wordlist.")
      :ok
    else
      guess = Enum.random(words)
      case API.guess(cookie, game_id, String.downcase(guess)) do
        # This is the winning case. We now capture the `data` from the API.
        {:ok, _feedback, true, data, _new_cookie} ->
          # The `data` map contains the API response. We extract the "answer".
          answer = Map.get(data, "answer", "(Answer not found in API response)")
          IO.puts("🎉 Solved! The word was: #{String.upcase(answer)}")

        {:ok, feedback, false, _data, new_cookie} ->
          new_words = dropImpossibles(words, guess, feedback)
          # IO.puts("After filtering, #{length(new_words)} words remain.")
          game_loop(new_words, new_cookie, game_id, attempt + 1)

        {:error, reason} ->
          IO.puts("Guess failed: #{reason}")
      end
    end
  end

  def dropImpossibles(possible_words, guess, feedback) do
    guess_chars = String.to_charlist(guess)
    feedback_chars = String.to_charlist(feedback)

    Enum.filter(possible_words, fn possible_word ->
      rules = Enum.zip(guess_chars, feedback_chars) |> Enum.with_index(0)

      Enum.all?(rules, fn{{guess_char, feedback_char} , index}->
        case feedback_char do
          ?R ->
            not String.contains?(possible_word, <<guess_char>>)
          ?Y ->
            String.contains?(possible_word, <<guess_char>>) and String.at(possible_word,index)!=<<guess_char>>
          ?G ->
            String.at(possible_word, index) == <<guess_char>>
          _ ->
            true
          end
      end)
    end)
  end
end

Wordle.run()
