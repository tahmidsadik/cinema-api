defmodule CinemaApi.DataPersistence do
  @moduledoc """
  provides functions for saving fetched movie data to database.
  """
  import Enum, only: [map: 2, filter: 2, member?: 2]
  import Ecto.Query, only: [from: 2]
  alias CinemaApi.Repo
  alias CinemaApi.Schemas.Movie
  alias CinemaApi.Schemas.Showtime
  # alias CinemaApi.Schemas.Showtime

  @doc """
  Persistence stretegy.
  1. Filter out the movies that are already saved in database and save the new ones with
  schedules

  2. Check the schedules of the remaining movies. Filter out the duplicate ones.
  Insert only the new ones.
  # Fun and profit.
  """
  def persist_movies(movies) do
    movies_with_showtimes = merge_with_showtimes(movies)

    new_showtimes = get_new_showtimes(movies_with_showtimes)

    persist_new_movies(get_new_movies(movies_with_showtimes))
    persist_showtimes(new_showtimes)
  end

  def merge_with_showtimes(movies) do
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
  end

  def get_new_movies(movies) do
    movies
    |> filter(&(!member?(get_saved_movie_titles(), &1.title)))
  end

  def get_new_showtimes(movies) do
    saved_movies =
      movies
      |> filter(&member?(get_saved_movie_titles(), &1.title))

    # list of showtimes from the provided movies
    fetched_showtimes = saved_movies |> map(fn m -> m.showtimes end) |> List.flatten()
    # fetch showtimes from db and checks if there are
    # any new showtimes by comparing them to the provided movies showtimes.
    # If there are, insert them.
    showtimes_from_db = get_saved_movie_showtimes_by_title(map(saved_movies, & &1.title))

    fetched_showtimes
    |> filter(fn showtime ->
      !Enum.any?(showtimes_from_db, fn saved_st ->
        saved_st.title == showtime.title && saved_st.cinemahall == showtime.cinemahall &&
          saved_st.showtime == showtime.showtime
      end)
    end)
  end

  def get_saved_movie_titles() do
    query =
      from(
        m in Movie,
        select: m.title
      )

    Repo.all(query)
  end

  def get_saved_movie_showtimes_by_title(titles) do
    query =
      from(
        s in Showtime,
        where: s.title in ^titles,
        select: %{title: s.title, showtime: s.showtime, cinemahall: s.cinemahall}
      )

    Repo.all(query)
  end

  def persist_new_movies(movies) do
    movies
    |> map(fn mov -> Movie.changeset(%Movie{}, mov) end)
    |> map(fn cset -> Repo.insert(cset) end)
  end

  def persist_showtimes(showtimes) do
    showtimes
    |> map(&Showtime.changeset(%Showtime{}, &1))
    |> map(&Repo.insert(&1))
  end
end
