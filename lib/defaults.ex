defmodule Defaults do

  @doc """
  opts:
  """
  def game(opts \\ []) do
    difficulty = Keywords.get(opts, :difficulty, :normal)
    nb_epidemic_cards = case difficulty do
                          :introductory -> 4
                          :normal -> 5
                          :heroic -> 6
                        end
    nb_players = Keywords.get(opts, :nb_players, 4)
  end


  def city_specs_from_raw_links(links) do
    city_specs = Enum.reduce links, Map.new(), fn ({city1,city2}, acc) ->
      l1 = Map.get acc, city1, []
      l2 = Map.get acc, city2, []
      acc
      |> Map.put(city1, [city2|l1])
      |> Map.put(city2, [city1|l2])
    end
    city_specs
  end
  
  def default_raw_links() do
    [
      # Connect all blues
      {:san_francisco, :chicago},
      {:chicago, :atlanta},
      {:chicago, :toronto},
      {:atlanta, :washington},
      {:toronto, :washington},
      {:toronto, :new_york},
      {:washington, :new_york},
      {:new_york, :madrid},
      {:new_york, :london},
      {:madrid, :london},
      {:madrid, :paris},
      {:london, :paris},
      {:london, :essen},
      {:paris, :essen},
      {:paris, :milan},
      {:essen, :milan},
      {:essen, :saint_petersburg},

      # Connect all blacks
      {:algiers, :paris},
      {:algiers, :madrid},
      {:algiers, :istanbul},
      {:algiers, :cairo},
      {:istanbul, :milan},
      {:istanbul, :cairo},
      {:istanbul, :baghdad},
      {:istanbul, :moscow},
      {:istanbul, :saint_petersburg},
      {:cairo, :baghdad},
      {:cairo, :riyadh},
      {:moscow, :saint_petersburg},
      {:baghdad, :riyadh},
      {:baghdad, :karachi},
      {:baghdad, :tehran},
      {:tehran, :moscow},
      {:riyadh, :karachi},
      {:tehran, :karachi},
      {:tehran, :delhi},
      {:karachi, :delhi},
      {:karachi, :mumbai},
      {:delhi, :kolkata},
      {:delhi, :mumbai},
      {:mumbai, :chennai},
      {:kolkata, :chennai},

      # Connect all reds
      {:jakarta, :bangkok},
      {:jakarta, :ho_chi_minh},
      {:jakarta, :chennai},
      {:jakarta, :sydney},
      {:sydney, :manila},
      {:bangkok, :chennai},
      {:bangkok, :kolkata},
      {:bangkok, :ho_chi_minh},
      {:bangkok, :hong_kong},
      {:ho_chi_minh, :manila},
      {:ho_chi_minh, :hong_kong},
      {:manila, :san_francisco},
      {:manila, :hong_kong},
      {:manila, :taipei},
      {:hong_kong, :taipei},
      {:hong_kong, :shanghai},
      {:hong_kong, :kolkata},
      {:taipei, :osaka},
      {:taipei, :shanghai},
      {:osaka, :tokyo},
      {:shanghai, :beijing},
      {:shanghai, :seoul},
      {:shanghai, :tokyo},
      {:beijing, :seoul},
      {:seoul, :tokyo},
      {:tokyo, :san_francisco},

      # Connect all yellows
      {:los_angeles, :sydney},
      {:los_angeles, :mexico_city},
      {:los_angeles, :san_francisco},
      {:los_angeles, :chicago},
      {:mexico_city, :miami},
      {:mexico_city, :chicago},
      {:mexico_city, :bogota},
      {:mexico_city, :lima},
      {:lima, :bogota},
      {:santiago, :lima},
      {:bogota, :miami},
      {:bogota, :sao_paulo},
      {:bogota, :buenos_aires},
      {:miami, :atlanta},
      {:miami, :washington},
      {:buenos_aires, :sao_paulo},
      {:sao_paulo, :madrid},
      {:sao_paulo, :lagos},
      {:lagos, :khartoum},
      {:lagos, :kinshasa},
      {:kinshasa, :khartoum},
      {:kinshasa, :johannesburg},
      {:johannesburg, :khartoum},
      {:khartoum, :cairo}]
  end
end