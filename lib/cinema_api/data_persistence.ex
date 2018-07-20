defmodule CinemaApi.DataPersistence do
  # TODO: Find a better name for this module
  @moduledoc """
  provides functions for saving fetched movie data to database.
  """
  import Enum, only: [map: 2]
  alias CinemaApi.Repo
  alias CinemaApi.Schemas.Movie
  # alias CinemaApi.Schemas.Showtime

  def persist_movies(movies) do
    movies
    |> map(fn mov ->
      Map.put(
        mov,
        :showtimes,
        mov.schedules
        |> map(fn showtime ->
          %{title: mov.title, cinemahall: "cineplex", imdb_id: mov.imdb_id, showtime: showtime}
        end)
      )
    end)
    |> map(fn mov -> Movie.changeset(%Movie{}, mov) end)
    |> map(fn cset -> Repo.insert(cset) end)
  end

  # def save_fetched_movies(movies) do
  #   movies
  #   |> reject(fn mov -> Repo.get_by(Movie, title: mov.title) end)
  #   |> map(&persist_movie/1)
  # end

  # def save_showtimes(movies) do
  #   movies
  #   |> map(fn mov ->
  #     %{
  #       title: mov.title,
  #       imdb_id: mov.imdb_id,
  #       showtimes: mov.schedules,
  #       cinemahall: mov.cinemahall
  #     }
  #   end)
  #   |> map(fn mov ->
  #     mov.showtimes
  #     |> map(fn showtime ->
  #       %{title: mov.title, imdb_id: mov.imdb_id, showtime: showtime, cinemahall: mov.cinemahall}
  #     end)
  #     |> map(fn showtime -> Showtime.changeset(%Showtime{}, showtime) end)
  #     |> map(fn cset -> cset |> Repo.insert() end)
  #   end)
  # end
end
