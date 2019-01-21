defmodule Calc do
  @moduledoc """
  Calc implements a modified version from the Dijkstra Shuting Yard
  algorithm to solve the evalution of basic math operations using the
  4 binary operators ( +, -, *, / ).

  This algorithm uses two stack as auxiliar data structures: var and op.

  At every token it checks:
    * If token is a number. Push token into var.
    * If token is a operator or a left parentheses. Push token into op.
    * If token is an right parentheses. It process all operations inside
  the parentheses and push it on top of var.

  The processing of a operator does as following:
    * It pops once from op(op_1) and twice(var_1, var_2) for var.
    * It apply the opererations in the right order- var_2 op_1 var_1.
    * And push the result on top of var.

  When the list of tokens is over it clean op by precessing all the
  operators in order.

  The final result should be the only element left on var.
  """

  import Calc.Tokenizer, only: [collect_tokens: 1]

  @typedoc """
  A list of tokens, numbers, operators or parentheses respresented as strings.
  """
  @type token_list :: [String.t] | [number]

  @doc """
  Process calculation string.

  The process starts by processing the string into an array of tokens.
  These tokens can be a number, a operator or parentheses, all represented as strings.

  ## Examples

      iex> Calc.process("2 + 2")
      4
      iex> Calc.process("3 * 2")
      6
      iex> Calc.process("3 - 2")
      1
      iex> Calc.process("6 / 3")
      2
      iex> Calc.process("(2 * 4) - 2")
      6
      iex> Calc.process("(4 * 3) / 2")
      6
  """
  @spec process(String.t) :: number
  def process(str), do: str |> collect_tokens |> parse([],[])

  @doc """
  Go through the list of tokens processing it accourding to it being:
    * a parentheses
    * an operator
    * a number
  """
  @spec parse(token_list, token_list, token_list) :: integer
  defp parse([], var, op), do: clean_op(var, op)
  defp parse([head | tail ], var, op) when head == "(", do: parse(tail, var, [head | op])
  defp parse([head | tail ], var, op) when head == ")", do: parse_right_parentheses(tail, var, op) 
  defp parse(list, var, op) when hd(list) in ["+", "-", "*", "/"], do: parse_operator(list, var, op)
  defp parse([head | tail ], var, op) do
    {n, _} = Integer.parse(head)
    parse(tail, [n | var], op)
  end
  
  @doc """
  Process all operations inside paramethers
  """
  @spec parse_right_parentheses(token_list, token_list, token_list) :: integer
  defp parse_right_parentheses(str, var, []), do: parse(str, var, [])
  defp parse_right_parentheses(str, var, ["(" | tail_op]), do: parse(str, var, tail_op)
  defp parse_right_parentheses(str, var, op) do
    {new_var, new_op} = process_operator(var, op)
    parse_right_parentheses(str, new_var, new_op)
  end

  @doc """
  Process operators in the right precedence
  """
  @spec parse_operator(token_list, token_list, token_list) :: integer
  defp parse_operator([head | tail], var, []), do: parse(tail, var, [head])
  defp parse_operator([head_str | tail_str], var, [head_op | tail_op]) do
    cond do
      precedence_position(head_op) >= precedence_position(head_str) ->
        {new_var, new_op} = process_operator(var, [head_op | tail_op])
        parse_operator([head_str | tail_str], new_var, new_op)
      true -> parse(tail_str, var, [head_str, head_op | tail_op])
    end
  end

  @doc """
  Returns the precedence of an operator
  """
  @spec precedence_position(String.t) :: integer
  defp precedence_position(token) do
    ~w(+ - * / ( \))
    |> Enum.with_index
    |> Enum.filter(fn {x, _} -> x == token end)
    |> Enum.map(fn {_, i} -> i end)
    |> List.first
  end

  @doc """
  Process operators by executing their operation.
  """
  @spec process_operator(token_list, token_list) :: {token_list, token_list}
  defp process_operator(var, ["(" | tail_op]), do: {var, tail_op}
  defp process_operator([x, y | tail_var], [op | tail_op]) do
    case op do
      "+" -> {[y + x | tail_var], tail_op}
      "-" -> {[y - x | tail_var], tail_op}
      "*" -> {[y * x | tail_var], tail_op}
      "/" -> {[div(y, x) | tail_var], tail_op}
    end
  end

  @doc """
  Process the remaining of var and op by just processing the rest of op.
  """
  @spec clean_op(token_list, token_list) :: integer
  defp clean_op(var, []), do: List.first var 
  defp clean_op(var, op) do
    {new_var, new_op} = process_operator(var, op)
    clean_op(new_var, new_op)
  end
end
