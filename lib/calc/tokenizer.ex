defmodule Calc.Tokenizer do
  @moduledoc """
  Tokenizer is responsable to separate the elements to be processed by Calc.

  Those tokens can be numbers, operators or parentheses.
  """

  @typedoc """
  A list of tokens, numbers, operators or parentheses respresented as strings.
  """
  @type token_list :: [String.t]
  
  
  @doc """
  Simply transforms the input into a list of String.Chars and send
  it to collect_tokens/2.

      iex> Calc.Tokenizer.collect_tokens("3 + 4")
      ["3", "+", "4"]
      iex> Calc.Tokenizer.collect_tokens("(3 * 4) - 2")
      ["(", "3", "*", "4", ")", "-", "2"]
  """
  @spec collect_tokens(String.t) :: token_list
  def collect_tokens(str) when is_binary(str), do: collect_tokens(String.to_charlist(str), [])

  @doc """
  Makes the selection of what to do with each char.
  Digits are acumulated using collect_tokens/3 so the token has of digits of the number.
  Operators are turned into strings and appended to the list of tokens.
  All the rest is discarded.
  """
  @spec collect_tokens(charlist(), token_list) :: token_list
  defp collect_tokens([], list), do: list
  defp collect_tokens([head | tail], list) do
    cond do
      head in '1234567890' -> collect_tokens(tail, list, [head])
      head in '+-*/()' -> collect_tokens(tail, list ++ [String.Chars.to_string([head])])
      true -> collect_tokens(tail, list)
    end
  end

  @doc """
  Is used to collect all the digits of a number before appending it to
  the list of tokens.
  """
  @spec collect_tokens(charlist(), token_list, charlist()) :: token_list
  defp collect_tokens([], list, acc), do: collect_tokens([], list ++ [String.Chars.to_string(acc)])
  defp collect_tokens([head | tail], list, acc) do
    cond do
      head in '1234567890' -> collect_tokens(tail, list, acc ++ [head])
      true -> collect_tokens([head | tail], list ++ [String.Chars.to_string(acc)])
    end
  end
end
