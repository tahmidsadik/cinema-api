defmodule CinemaApi.DataProvider do
  @moduledoc """
  Higher level API for providing movie data from different sources
  i.e. Cineplex, Blockbuster Cinema, Shaymoli Cinema etc.
  """

  import Enum, only: [map: 2]

  import CinemaApi.Cineplex.Fetcher, only: [get_markup: 0]

  import CinemaApi.Cineplex.Parser,
    only: [
      parse_cineplex_movies: 1,
      add_original_movie_titles_to_fetched_movies: 2,
      add_movie_schedules_to_fetched_movies: 2,
      parse_release_date: 1,
      normalize_cineplex_movie_schedules: 1,
      add_original_movie_info_to_fetched_movies: 2
    ]

  import CinemaApi.OMDB,
    only: [prepare_omdb_request_url_from_movie_names: 1, fetch_parallel: 1, parse_response: 1]

  def create_imdb_movie(responses) do
    responses
    |> map(fn r ->
      %{
        imdb_id: r["imdbID"],
        title: r["Title"],
        year: r["Year"],
        release_date: parse_release_date(r["Released"]),
        runtime: r["Runtime"],
        genre: r["Genre"],
        director: r["Director"],
        actors: r["Actors"],
        plot: r["Plot"],
        language: r["Language"],
        country: r["Country"],
        awards: r["Awards"],
        imdb_rating: r["imdbRating"],
        # rotten_tomatoes_rating: at(r["Ratings"], 2),
        # metacritic_rating: r["Ratings"] |> at(2) |> elem(1),
        poster: r["Poster"],
        media_type: r["Type"],
        box_office: r["BoxOffice"],
        production: r["Production"],
        website: r["Website"],
        schedules: r[:schedules][r["cineplex_title"]],
        cineplex_title: r["cineplex_title"],
        original_info: r["original_info"]
      }
    end)
  end

  def get_cineplex_movies do
    case get_markup() do
      {:ok, body} ->
        {:ok, parse_cineplex_movies(body)}

      {:err, msg} ->
        IO.puts(msg)
        {:err, msg}
    end
  end

  @doc """
  returns cineplex movies with added info fetched from the omdb api
  """
  def get_cineplex_movies_with_omdb_data() do
    case get_cineplex_movies() do
      {:ok, movie_data} ->
        movies = movie_data.movie_list

        movies
        |> prepare_omdb_request_url_from_movie_names
        |> fetch_parallel
        |> parse_response
        |> add_original_movie_titles_to_fetched_movies(movie_data.movie_list)
        |> add_movie_schedules_to_fetched_movies(
          normalize_cineplex_movie_schedules(movie_data.movie_with_showtime)
        )
        |> add_original_movie_info_to_fetched_movies(movie_data.original_info)
        |> create_imdb_movie

      {:err, msg} ->
        msg
    end
  end
end
