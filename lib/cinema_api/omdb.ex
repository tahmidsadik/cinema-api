defmodule CinemaApi.OMDB do
  @moduledoc """
  Provides functions for preparing and fetching
  IMDB data through OMDB API
  """

  import Enum, only: [map: 2, filter: 2]

  def prepare_omdb_request_url_from_movie_names(uniq_movie_list) do
    omdb_api_key = Application.get_env(:cinema_api, CinemaApi.CinemaInfoFetcher)[:omdb_api_key]
    omdb_url = "https://www.omdbapi.com/"

    uniq_movie_list
    |> map(fn movie -> String.replace(movie, " ", "+") end)
    |> map(fn movie -> omdb_url <> "?t=" <> movie <> "&apikey=" <> omdb_api_key end)
  end

  def fetch_parallel(list_of_urls) do
    list_of_urls
    |> map(fn url -> Task.async(fn -> HTTPoison.get(url) end) end)
    |> map(&Task.await/1)
    |> map(fn response ->
      case response do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          %{
            error: false,
            body: body,
            errMessage: nil
          }

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          %{
            error: true,
            body: nil,
            errMessage: "Could not find the requested resource"
          }

        {:ok, %HTTPoison.Response{status_code: 500}} ->
          %{
            error: true,
            body: nil,
            errMessage: "Internal Server Error"
          }

        {:error, %HTTPoison.Error{id: id, reason: reason}} ->
          %{
            error: true,
            body: nil,
            errMessage: reason,
            id: id
          }
      end
    end)
  end

  def prepare_tmdb_url_from_imdb_id(imdb_ids) do
    tmdb_api_version =
      Application.get_env(:cinema_api, CinemaApi.CinemaInfoFetcher)[:tmdb_api_version]

    tmdb_api_key = Application.get_env(:cinema_api, CinemaApi.CinemaInfoFetcher)[:tmdb_api_key_v3]
    tmdb_base_url = "https://api.themoviedb.org/"
    tmdb_url = tmdb_base_url <> "/" <> tmdb_api_version

    # we are using the /find endpoint here. it acceps external # ids like IMDB_ID, which is what we will be using
    imdb_ids
    |> map(fn imdb_id ->
      tmdb_url <> "/find/" <> imdb_id <> "?api_key=" <> tmdb_api_key <> "&external_source=imdb_id"
    end)
  end

  def fetch_poster_from_tmdb(imdb_ids) do
    imdb_ids
    |> prepare_tmdb_url_from_imdb_id
    |> fetch_parallel
    |> parse_response
    |> map(fn n -> n["movie_results"] end)
    |> List.flatten()
    |> Enum.map(fn n ->
      %{
        tmdb_poster: n["poster_path"],
        backdrop: n["backdrop_path"]
      }
    end)
  end

  # def add_tmdb_images_to_movie_data do
  #   data = get_cineplex_movies_with_omdb_data()
  #   imdb_ids = map(data, fn m -> m.imdb_id end)
  #   image_links = fetch_poster_from_tmdb(imdb_ids)

  #   zip(data, image_links)
  #   |> map(fn n -> Map.merge(elem(n, 0), elem(n, 1)) end)
  # end

  def parse_response(responses) do
    responses
    |> filter(fn response -> !response.error end)
    |> map(fn response -> Poison.decode!(response.body) end)
  end
end
