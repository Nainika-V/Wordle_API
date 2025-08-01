defmodule WordleGame do
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

  def run do
    file_path = "5words.txt"
    case File.read(file_path) do
      {:ok, content} ->
        words = content |> String.split("\n", trim: true)

        {_final_words, final_attempt} = Enum.reduce_while(1..6, {words, 1}, fn attempt, {remaining_words, _attempt_number} ->
          IO.puts "\n --Attempt #{attempt} -- "

          guess_word = Enum.random(remaining_words)
          IO.puts "Chosen Word: #{guess_word}"

          IO.puts "Enter feedback for '#{guess_word}' in R/Y/G format (e.g., RRYYG):"
          feedback = IO.gets("") |> String.trim()
          IO.puts "You entered feedback: #{feedback}"

          if feedback == "GGGGG" do
            IO.puts "Yay! I find your hidden word!"
            {:halt, {remaining_words, attempt}}
          else
            new_remaining_words = dropImpossibles(remaining_words, guess_word, feedback)
            IO.puts "Remaining words #{inspect(new_remaining_words)}"

            if Enum.empty?(new_remaining_words) do
              IO.puts "Out of words! Check feedback!"
              {:halt, {new_remaining_words, attempt}}
            else
              {:cont, {new_remaining_words, attempt}}
            end
          end
        end)
        if final_attempt == 6 do
          IO.puts "Oops! Try again."
        end
      end
  end
end

WordleGame.run()
