defmodule Translator do
  def start() do
    spawn(&loop/0)
  end

  def loop() do
    loop(%{}, %Translator.State{})
  end

  def translate_word(translations, word) do
    if(Map.has_key?(translations, word)) do
      Map.get(translations, word)
    else
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

  def update_state(translation, state) do
    new_frequency =
      translation
      |> String.split(" ")
      |> Enum.frequencies()
      |> Map.merge(state.word_frequency)

    length =
      translation
      |> String.split(" ")
      |> Kernel.length()

    new_count =
      case length > 1 do
        true -> state.doc_count + 1
        _ -> state.doc_count
      end

    %{state | word_frequency: new_frequency, doc_count: new_count}
  end

  def loop(translations, state) do
    receive do
      {:register_translation, from, word, translation} ->
        send(from, {:registered, word <> " = " <> translation})
        loop(Map.put(translations, word, translation), state)

      {:translate, from, words} ->
        translated_text = translate_doc(translations, words)
        send(from, {:translation, translated_text})
        loop(translations, update_state(translated_text, state))

      {:stats, from} ->
        send(from, {:stats, state})
        loop(translations, state)

      other ->
        IO.puts("Error: Unknown request type = " <> other)
        IO.inspect(other)
        loop(translations, state)
    end
  end
end
