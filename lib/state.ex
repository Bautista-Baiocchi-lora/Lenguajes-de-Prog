defmodule Translator.State do
  defstruct word_frequency: %{}, doc_count: 0

  def new(frequency, count) do
    %Translator.State{
      word_frequency: frequency,
      doc_count: count
    }
  end
end
