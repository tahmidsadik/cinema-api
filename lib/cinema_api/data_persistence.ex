defmodule CinemaApi.DataPersistence do
  @moduledoc """
  Provides functions to persist movies
  TODO: Add tests. High Priority.
  """
  import Enum, only: [map: 2, filter: 2, member?: 2]
  import Ecto.Query, only: [from: 2]
  alias CinemaApi.Repo
  alias CinemaApi.Schemas.Movie
  alias CinemaApi.Schemas.Showtime

  @doc """
  Persistence stretegy.
  1. Filter out the movies that are already saved in database and save the new ones with
  schedules

  2. Check the schedules of the remaining movies. Filter out the duplicate ones.
  Insert only the new ones.
  # Fun and profit.
  """
  @spec persist_movies([Movie.movie()]) :: [
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
        ]
  def persist_movies(movies) do
    movies_with_showtimes = merge_with_showtimes(movies)

    new_showtimes = get_new_showtimes(movies_with_showtimes)

    persist_new_movies(get_new_movies(movies_with_showtimes))
    persist_showtimes(new_showtimes)
  end

  @spec merge_with_showtimes(list(Movie.movie())) :: list(Movie.movie())
  defp merge_with_showtimes(movies) do
    movies
    |> map(fn mov ->
      Map.put(
        mov,
        :showtimes,
        mov.schedules
        |> map(fn showtime ->
          %{
            title: mov.title,
            cinemahall: "cineplex",
            imdb_id: mov.imdb_id,
            showtime: DateTime.from_naive!(showtime, "Etc/UTC")
          }
        end)
      )
    end)
  end

  @spec get_saved_movies_with_injected_id([Movie.movie()]) :: [Movie.movie()]
  defp get_saved_movies_with_injected_id(movies) do
    movies
    |> filter(&member?(get_saved_movie_titles(), &1.title))
    |> map(&Map.put(&1, :id, Repo.get_by(Movie, title: &1.title).id))
    |> map(
      &Map.put(
        &1,
        :showtimes,
        &1.showtimes |> map(fn showtime -> Map.put(showtime, :movie_id, &1.id) end)
      )
    )
  end

  @spec get_new_movies([Movie.movie()]) :: [Movie.movie()]
  defp get_new_movies(movies) do
    movies
    |> filter(&(!member?(get_saved_movie_titles(), &1.title)))
  end

  @spec get_new_showtimes([Movie.movie()]) :: [Movie.showtime()]
  defp get_new_showtimes(movies) do
    saved_movies = get_saved_movies_with_injected_id(movies)
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
          DateTime.compare(saved_st.showtime, showtime.showtime) == :eq
      end)
    end)
  end

  @spec get_saved_movie_titles() :: [String.t()]
  defp get_saved_movie_titles() do
    query =
      from(
        m in Movie,
        select: m.title
      )

    Repo.all(query)
  end

  @spec get_saved_movie_showtimes_by_title([String.t()]) :: [
          %{title: String.t(), showtime: String.t(), cinemahall: String.t()}
        ]
  defp get_saved_movie_showtimes_by_title(titles) do
    query =
      from(
        s in Showtime,
        where: s.title in ^titles,
        select: %{title: s.title, showtime: s.showtime, cinemahall: s.cinemahall}
      )

    Repo.all(query)
  end

  @spec persist_new_movies([Movie.movie()]) :: [
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
        ]
  defp persist_new_movies(movies) do
    movies
    |> map(fn mov -> Movie.changeset(%Movie{}, mov) end)
    |> map(fn cset -> Repo.insert(cset) end)
  end

  @spec persist_showtimes([Movie.showtime()]) :: [
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
        ]
  defp persist_showtimes(showtimes) do
    showtimes
    |> map(&Showtime.changeset(%Showtime{}, &1))
    |> map(&Repo.insert(&1))
  end
end
