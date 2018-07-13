defmodule CinemaApi.DataPersistence do
  # TODO: Find a better name for this module
  @moduledoc """
  provides functions for saving fetched movie data to database.
  """
  import CinemaApi.Schemas.Movie, only: [changeset: 2]
  import Enum, only: [map: 2, all?: 2]
  alias CinemaApi.Schemas.Movie
  alias CinemaApi.Schemas.Showtime

  def save_fetched_movies(movies) do
    changesets =
      movies
      |> map(fn mov -> changeset(%Movie{}, mov) end)

    case all?(changesets, fn c -> c.valid? end) do
      true ->
        changesets
        |> map(fn cset -> cset |> CinemaApi.Repo.insert() end)

      false ->
        {:err, "Couldn't save fetched movie info. Not all changesets are valid"}
    end
  end

  def save_showtimes(movies) do
    movies
    |> map(fn mov ->
      %{
        title: mov.title,
        imdb_id: mov.imdb_id,
        showtimes: mov.schedules,
        cinemahall: mov.cinemahall
      }
    end)
    |> map(fn mov ->
      mov.showtimes
      |> map(fn showtime ->
        %{title: mov.title, imdb_id: mov.imdb_id, showtime: showtime, cinemahall: mov.cinemahall}
      end)
      |> map(fn showtime -> Showtime.changeset(%Showtime{}, showtime) end)
      |> map(fn cset -> cset |> CinemaApi.Repo.insert() end)
    end)
  end
end
