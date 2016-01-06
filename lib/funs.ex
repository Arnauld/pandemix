defmodule Funs do
  def identity(value) do
    value
  end

  @doc """
  
  """
  def distribute(values, n) when is_list(values) and is_integer(n) do
    count = Enum.count(values)
    nb_per_chunk = div count, n
    remaining = rem count, n
    distribute [], nb_per_chunk, remaining, values, n
  end

  defp distribute(acc, _nb_per_chunk, 0, [], 0) do
    acc
  end
  
  defp distribute(acc, nb_per_chunk, remaining, values, n) do
    {d, new_remaining} = case remaining do
                          0 -> {0, 0}
                          _ -> {1, remaining - 1}
                         end
    nb = nb_per_chunk + d
    elems = Enum.take values, nb
    new_values = Enum.drop values, nb
    distribute([elems|acc], nb_per_chunk, new_remaining, new_values, n - 1)
  end

end