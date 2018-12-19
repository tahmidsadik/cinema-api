defmodule CinemaApi.Cineplex.Parser do
  @moduledoc """
  Provides functions for parsing fetched cineplex movie data.
  """
  import Enum, only: [map: 2, filter: 2, at: 2, count: 1, into: 2, zip: 2, uniq: 1, slice: 2]
  import List, only: [foldl: 3]
  import Timex, only: [parse: 2, parse: 3]

  import CinemaApi.Cineplex.Fetcher,
    only: [
      get_movie_times: 1,
      get_movie_dates: 1,
      get_movie_names: 1,
      get_movie_links: 1,
      fetch_all_movies_original_info: 1
    ]

  @doc """
  takes a month in string format and returns the index of that month
  i.e. January -> 1
       Jan -> 1
  """
  def parse_month_string_to_int(month) do
    case month do
      n when n in ["January", "Jan"] -> 1
      n when n in ["February", "Feb"] -> 2
      n when n in ["March", "Mar"] -> 3
      n when n in ["April", "Apr"] -> 4
      n when n in ["May"] -> 5
      n when n in ["June", "Jun"] -> 6
      n when n in ["July", "Jul"] -> 7
      n when n in ["August", "Aug"] -> 8
      n when n in ["September", "Sep"] -> 9
      n when n in ["October", "Oct"] -> 10
      n when n in ["November", "Nov"] -> 11
      n when n in ["December", "Dec"] -> 12
    end
  end

  @doc """
  takes a string and substring and returns how many times that string appears
  in that string
  iex > substr_frequency("14-Dec-2018", "-")
  iex > 2
  iex > substr_frequency("14 Dec 2018", "-")
  iex > 0
  """
  def substr_frequency(str, search_term) do
    len =
      str
      |> String.split(search_term)
      |> Enum.count()

    len - 1
  end

  @doc """
  takes a date in string format. Format is  "23 May 2018".
  Returns equivalent elixir date.
  """
  def parse_release_date(release_date) do
    # TODO: Fix this fucntion, add more checks like literal words instead of
    # dates are provided
    case release_date do
      "" ->
        nil

      "N/A" ->
        nil

      "Coming Soon" ->
        nil

      n ->
        case n |> substr_frequency("-") do
          2 ->
            [day, month, year] = String.split(release_date, "-")
            day = String.trim(day)
            month = String.trim(month)
            year = String.trim(year)
            trimmed_rdate = day <> "-" <> month <> "-" <> year

            case String.length(year) do
              2 ->
                {:ok, date} = Timex.parse(trimmed_rdate, "%d-%m-%y", :strftime)
                date

              4 ->
                {:ok, date} = Timex.parse(trimmed_rdate, "%d-%m-%Y", :strftime)
                date
            end

          1 ->
            {:ok, date} = Timex.parse(n, "%d %b-%Y", :strftime)
            date

          0 ->
            [day | [month | [year | _]]] =
              n
              |> String.split()

            {:ok, date} =
              Date.new(
                String.to_integer(year),
                parse_month_string_to_int(month),
                String.to_integer(day)
              )

            date
        end
    end
  end

  @doc """
  Takes a list of movies and discards 2D/3D info from it.
  Removes 2D or 3D information from the fetched cineplex movie list.
  """
  def discard_2d_3d_from_movie_name(movies) do
    movies
    |> Enum.map(fn n -> discard_3d_info_from_cineplex_movie(n) end)
  end

  @doc """
  Takes a movie and discards 2D/3D info from it.
  """
  def discard_3d_info_from_cineplex_movie(movie) do
    String.replace(movie, ~r/\(\s*\dD\)/, "") |> String.trim()
  end

  def normalize_date_format(date) do
    d =
      date
      |> String.split(",")
      |> slice(1..-1)
      |> map(fn n -> String.trim(n) end)

    day = at(d, 0) |> String.split() |> at(1) |> String.to_integer()
    month = at(d, 0) |> String.split() |> at(0) |> parse_month_string_to_int
    year = at(d, 1) |> String.to_integer()

    %{
      :day => day,
      :month => month,
      :year => year
    }
  end

  def normalize_time_format(time) do
    t =
      time
      |> String.replace(~r/AM|PM/, "")
      |> String.trim()
      |> String.split(":")

    time_period =
      time
      |> String.split(~r/\d{2}:\d{2}/)
      |> at(1)

    hour =
      case time_period do
        "AM" ->
          case at(t, 0) do
            "12" -> 0
            n -> String.to_integer(n) |> Kernel.+(12)
          end

        "PM" ->
          case at(t, 0) do
            "12" -> 12
            n -> String.to_integer(n) + 12
          end
      end

    minute = at(t, 1) |> String.to_integer()
    second = 0

    %{
      :hour => hour,
      :minute => minute,
      :second => second
    }
  end

  def prepare_movie_title(movies) do
    movies
    |> map(fn movie -> String.replace(movie, ~r/\(\s*\dD\)/, "") |> String.trim() end)
  end

  def normalize_movie_dates(movie_dates) do
    movie_dates
    |> map(fn date -> normalize_date_format(date) end)
  end

  def get_unique_movies(movies) do
    movies
    |> List.flatten()
    |> uniq()
    |> discard_2d_3d_from_movie_name()
  end

  def merge_movie_date_time(movie_dates, movie_times) do
    zip(normalize_movie_dates(movie_dates), movie_times)
    |> map(fn date_time_pair ->
      date = elem(date_time_pair, 0)

      map(elem(date_time_pair, 1), fn times ->
        String.split(times)
        |> map(fn time ->
          t = normalize_time_format(time)

          {:ok, showtime} =
            NaiveDateTime.new(date.year, date.month, date.day, t.hour, t.minute, t.second)

          showtime
        end)
      end)
    end)
  end

  def merge_movie_with_showtime(movie_names, showtimes) do
    for i <- 0..(count(movie_names) - 1),
        do:
          zip(at(movie_names, i), at(showtimes, i))
          |> into(%{})
  end

  def normalize_cineplex_movie_schedules(showtimes) do
    showtimes
    |> foldl(%{}, fn movie, acc -> Map.merge(movie, acc, fn _, v1, v2 -> v1 ++ v2 end) end)
    |> map(fn {name, showtime} ->
      {discard_3d_info_from_cineplex_movie(name), uniq(showtime)}
    end)
    |> Enum.into(%{})
  end

  @doc """
  Remove movies from the response for which IMDB response's were not found
  """
  def remove_non_imdb_movies(data) do
    data
    |> filter(fn movie -> movie["Response"] == "True" end)
  end

  def add_original_movie_titles_to_fetched_movies(movies, titles) do
    movies
    |> zip(titles)
    |> map(fn movie -> Map.put(elem(movie, 0), "cineplex_title", elem(movie, 1)) end)
  end

  def add_original_movie_info_to_fetched_movies(movies, infos) do
    movies
    |> zip(infos)
    |> map(fn movie -> Map.put(elem(movie, 0), "original_info", elem(movie, 1)) end)
  end

  def add_movie_schedules_to_fetched_movies(movies, schedules) do
    movies
    |> map(fn movie -> Map.put(movie, :schedules, schedules) end)
  end

  @doc """
  Creates a movie MAP from OMDB response
  """

  def parse_cineplex_movies(markup) do
    parsed_body = Floki.parse(markup)
    movie_names = get_movie_names(parsed_body)
    movie_times = get_movie_times(parsed_body)
    movie_dates = get_movie_dates(parsed_body)
    movie_links = get_movie_links(parsed_body)
    original_movie_infos = fetch_all_movies_original_info(movie_links)
    showtimes = merge_movie_date_time(movie_dates, movie_times)
    movie_with_showtimes = merge_movie_with_showtime(movie_names, showtimes)
    movie_names_uniq = get_unique_movies(movie_names)

    movie_data = %{
      :movie_list => movie_names_uniq,
      :movie_with_showtime => movie_with_showtimes,
      :original_info => original_movie_infos
    }

    movie_data
  end
end
