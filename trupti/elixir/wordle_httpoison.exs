defmodule API do
  Mix.install([
    {:httpoison, "~> 1.8"},
    {:jason, "~> 1.2"}
  ])

    @base_url  "https://wordle.we4shakthi.in/game"
    @default_headers  [{"Content-Type", "application/json"}]

    defp extract_session_cookie(headers) do
      Enum.find_value(headers, fn
        {header_name, val} when is_binary(header_name) ->
        case String.downcase(header_name) do
          "set-cookie" -> val |> String.split(";") |> List.first()
          _-> nil
        end
        _ -> nil
        end)
    end

    defp make_request(method, endpoint, body, cookie) do
      url = "#{@base_url}/#{endpoint}"
      headers = if cookie , do: @default_headers ++ [{"Cookie", cookie}], else: @default_headers

      case HTTPoison.request(method, url, body, headers) do
        {:ok, %HTTPoison.Response{status_code: code, body: response, headers: resp_headers}} when code in [200, 201] ->
        case Jason.decode(response) do
          {:ok, data} -> {:ok, code, data, resp_headers}
          {:error, _} -> {:error, "Invalid JSON response"}
        end

        {:ok, %HTTPoison.Response{status_code: code, body: response}} ->
          IO.puts("⚠️ Failed: #{code}\n#{response}")
          {:error, "API Error #{code}: #{inspect(response)}"}

        {:error, %HTTPoison.Error{reason: reason}} ->
          IO.puts("❌ Error: #{inspect(reason)}")
          {:error, "HTTP Error: #{inspect(reason)}"}
      end
    end

  def register do
    random_name = "trupti_#{System.os_time()}"
    body = Jason.encode!(%{"mode" => "wordle", "name" => random_name})

    case make_request(:post, "register", body, nil) do
      {:ok, _code, %{"id" => user_id}, headers} ->
        case extract_session_cookie(headers) do
          nil ->
            {:error, "No session cookie received"}
          cookie ->
            IO.puts("Registered for the game.")
            {:ok, cookie, user_id}
        end
      {:error, reason} ->
        IO.puts("❌ Registration failed: #{reason}")
        {:error, reason}
    end
  end

  def create(cookie, user_id) do
    body = Jason.encode!(%{"id" => user_id , "overwrite" => true})
    case make_request(:post, "create", body, cookie) do

      {:ok, _code, %{"created" => true } = _data, headers} ->
        IO.puts("Created game successfully.")
        case extract_session_cookie(headers) do
          nil -> {:ok, cookie, user_id}
          new_cookie -> {:ok, new_cookie, user_id}
        end

      {:ok, _code, data, _headers} ->
        IO.puts("Created!! but no game_id response. full data :#{inspect(data)}")
        {:error, "Unexpected create response"}

      {:error, reason} ->
        IO.puts("Creation failed. #{reason}")
        {:error, reason}
    end
  end

  defp format_feedback(feedback) when is_list(feedback) do
    feedback |> Enum.join("")
  end

  defp format_feedback(feedback) when is_binary(feedback), do: feedback

  defp format_feedback(_), do: "Invalid feedback format"


  def guess(cookie, id, word) do
    body = Jason.encode!(%{"guess" => word, "id" => id})

    # FIX: Corrected the entire case statement for clarity and correctness
    case make_request(:post, "guess", body, cookie) do
      {:ok, _code, %{"feedback" => feedback} = data, headers} ->
        formatted_feedback = format_feedback(feedback)
        IO.puts("📝 Guess: #{word}")
        IO.puts("🎯 Feedback: #{formatted_feedback}")

        # FIX: Correctly check if the feedback is exactly "GGGGG"
        won = formatted_feedback == "GGGGG"
        if won, do: IO.puts("🎉 You won!")

        new_cookie = extract_session_cookie(headers) || cookie
        {:ok, formatted_feedback, won, data, new_cookie}

      {:ok, _code, data, _headers} ->
        # This handles cases where the server responds 200 OK but without feedback
        IO.puts("⚠️ No feedback received for guess: #{word}. Full data: #{inspect(data)}")
        {:error, "No feedback in API response"}

      {:error, reason} ->
        IO.puts("❌ Guess '#{word}' failed: #{reason}")
        {:error, reason}
    end
  end

end
