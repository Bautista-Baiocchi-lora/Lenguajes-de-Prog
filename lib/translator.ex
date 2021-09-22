defmodule Translator do
  defmodule State do
    defstruct translated_words: %{}, translated_docs: 0
  end

  def start() do
    spawn(&loop/0)
  end

  def loop() do
    loop(%{}, %State{})
  end

  def translate_word(translations, word) do
    cond do
      Map.has_key?(translations, word) ->
        Map.get(translations, word)

      true ->
        "NULL"
    end
  end

  def translate_doc(translations, doc) do
    doc
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(fn x -> translate_word(translations, x) end)
    |> Enum.join(" ")
  end

  def loop(translations, state) do
    receive do
      {:register_translation, from, word, translation} ->
        send(from, {:registered, word <> " = " <> translation})
        loop(Map.put(translations, word, translation), state)

      {:translate, from, words} ->
        send(from, {:translation, translate_doc(translations, words)})
        loop(translations, state)

      {:stats, from} ->
        IO.puts("Stats requested")
        loop(translations, state)

      other ->
        IO.puts("Error: Unknown request type = " <> other)
        IO.inspect(other)
        loop(translations, state)
    end
  end
end
