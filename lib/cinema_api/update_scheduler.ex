defmodule CinemaApi.DataUpdateScheduler do
  use Task

  @moduledoc """
  Provides functions for schedule tasks to execute periodically.
  """

  @spec start_link() :: {:ok, pid()}
  def start_link() do
    IO.puts("Task Init. Fetching New movies...")
    Task.start_link(&poll/0)
  end

  @spec poll() :: no_return()
  def poll() do
    IO.puts("Task polling...")

    receive do
    after
      1000 * 60 * 60 ->
        update_movie_data()
        poll()
    end
  end

  def update_movie_data() do
    CinemaApi.DataProvider.get_cineplex_movies_with_omdb_data()
    |> CinemaApi.DataPersistence.persist_movies()
  end
end
