defmodule CinemaApi.Movies do
  @moduledoc """
  provides functions for getting currently showing movies and showtimes from db
  """
  alias CinemaApi.Schemas.Movie
  alias CinemaApi.Schemas.Showtime
  alias CinemaApi.Repo
  import Ecto.Query
  import Enum, only: [map: 2, zip: 2, filter: 2]
  import Map, only: [from_struct: 1, delete: 2]

  def get_movies() do
    movies = Repo.all(from(m in Movie, preload: [:showtimes]))

    movies
    |> map(fn mov -> mov |> from_struct() |> delete(:__meta__) end)
    |> map(fn mov ->
      %{
        mov
        | showtimes: mov.showtimes |> map(fn st -> st |> from_struct() |> delete(:__meta__) end)
      }
    end)
  end
end
