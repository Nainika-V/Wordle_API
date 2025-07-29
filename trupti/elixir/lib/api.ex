defmodule API do
  def register do
    url = "https://wordle.we4shakthi.in/game/register"
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(%{"mode" => "wordle", "name" => "trupti"})

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: code, body: response, headers: resp_headers}} when code in [200, 201] ->
        IO.puts("✅ Registered!")
        %{"id" => id} = Jason.decode!(response)

        IO.inspect(resp_headers, label: "📦 Raw Headers")

        session_cookie =
          resp_headers
          |> Enum.map(fn {k, v} -> {String.downcase(k), v} end)
          |> Enum.find_value(fn
            {"set-cookie", val} -> String.split(val, ";") |> hd()
            _ -> nil
          end)

        IO.puts("🪪 ID: #{id}")
        IO.puts("🍪 Cookie: #{session_cookie}")
        {session_cookie, id}

      {:ok, %HTTPoison.Response{status_code: code, body: response}} ->
        IO.puts("⚠️ Registration Failed: #{code}\n#{response}")
        nil

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("❌ Registration Error: #{inspect(reason)}")
        nil
    end
  end

  def create(session_cookie, id) do
    url = "https://wordle.we4shakthi.in/game/create"
    headers = [
      {"Content-Type", "application/json"},
      {"Cookie", session_cookie}
    ]
    body = Jason.encode!(%{"id" => id, "overwrite" => true})

    IO.inspect(headers, label: "📨 Headers Sent in CREATE")

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 201, body: response}} ->
        IO.puts("✅ Game Created!")
        IO.puts("Response: #{response}")
        :ok

      {:ok, %HTTPoison.Response{status_code: code, body: response}} ->
        IO.puts("⚠️ Game Creation Failed: #{code}\n#{response}")
        :error

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("❌ Error in Game Creation: #{inspect(reason)}")
        :error
    end
  end

  def guess(session_cookie, id) do
    words = ["apple", "grape", "plumb", "sugar", "mango"] # Replace with better guesses if needed

    Enum.each(0..4, fn i ->
      guess_word = Enum.at(words, i)
      url = "https://wordle.we4shakthi.in/game/guess"
      headers = [
        {"Content-Type", "application/json"},
        {"Cookie", session_cookie}
      ]
      body = Jason.encode!(%{"guess" => guess_word, "id" => id})

      IO.inspect(headers, label: "📨 Headers Sent in GUESS #{i + 1}")

      case HTTPoison.post(url, body, headers) do
        {:ok, %HTTPoison.Response{status_code: code, body: response}} when code in [200, 201] ->
          case Jason.decode(response) do
            %{"feedback" => feedback} ->
              IO.puts("📝 Guess #{i + 1}: #{guess_word}")
              IO.puts("🎯 Feedback: #{inspect(feedback)}\n")
            _ ->
              IO.puts("⚠️ Could not decode feedback for guess #{i + 1}: #{response}")
          end

        {:ok, %HTTPoison.Response{status_code: code, body: response}} ->
          IO.puts("❌ Guess #{i + 1} Failed (#{code}): #{response}\n")

        {:error, %HTTPoison.Error{reason: reason}} ->
          IO.puts("❌ Guess #{i + 1} Error: #{inspect(reason)}\n")
      end

      :timer.sleep(500)
    end)
  end

  def start do
    case register() do
      {cookie, id} ->
        :timer.sleep(1000)
        case create(cookie, id) do
          :ok ->
            :timer.sleep(1000)
            guess(cookie, id)
          _ ->
            IO.puts("⚠️ Could not create game. Aborting guesses.")
        end
      _ ->
        IO.puts("❌ Failed to register. Aborting.")
    end
  end
end 
