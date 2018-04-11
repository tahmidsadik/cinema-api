defmodule CinemaApi.CinemaInfoFetcher do
  import Enum, only: [map: 2, filter: 2, at: 2, count: 1, into: 2, zip: 2, uniq: 1, slice: 2]

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

  def parse_release_date(release_date) do
    # date format is "23 May 2018"
    [day | [month | [year | _]]] =
      release_date
      |> String.split()

    {:ok, date} =
      Date.new(String.to_integer(year), parse_month_string_to_int(month), String.to_integer(day))

    date
  end

  # def parse_runtime(runtime) do
  #   # runtime format "136 min"
  #   [minute | _] = String.split(runtime)

  #   {:ok, rtime} = Time.new(0, minute, 0, 0)
  #   rtime
  # end

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
        "AM" -> at(t, 0) |> String.to_integer()
        "PM" -> at(t, 0) |> String.to_integer() |> Kernel.+(12)
      end

    minute = at(t, 1) |> String.to_integer()
    second = 0

    %{
      :hour => hour,
      :minute => minute,
      :second => second
    }
  end

  def normalize_movie_dates(movie_dates) do
    movie_dates
    |> map(fn date -> normalize_date_format(date) end)
  end

  def get_movie_times(parsed_html_body) do
    parsed_html_body
    |> Floki.find(".col-lg-8 .col-xs-12")
    |> map(fn n -> Floki.find(n, ".items-wrap") end)
    |> map(fn n ->
      map(n, fn x ->
        x
        |> Floki.find("li")
        |> Floki.text()
        |> String.trim()
        |> String.replace(" ", "")
        |> String.replace("\n", " ")
      end)
    end)
  end

  def get_movie_dates(parsed_html_body) do
    parsed_html_body
    |> Floki.find(".date-tx")
    |> map(fn n -> n |> Floki.find("strong") |> Floki.text() end)
  end

  def get_movie_names(parsed_html_body) do
    parsed_html_body
    |> Floki.find(".col-lg-8 .col-xs-12")
    |> map(fn block -> Floki.find(block, ".text-info") end)
    |> map(fn n -> map(n, fn x -> Floki.text(x) end) end)
    |> map(fn n ->
      map(n, fn x ->
        x
        |> String.trim()
        |> String.replace("\n", "")
      end)
    end)
  end

  def get_unique_movies(movie_list) do
    movie_list
    |> List.flatten()
    |> uniq()
  end

  def merge_movie_date_time(movie_dates, movie_times) do
    zip(normalize_movie_dates(movie_dates), movie_times)
    |> map(fn date_time_pair ->
      date = elem(date_time_pair, 0)

      map(elem(date_time_pair, 1), fn times ->
        String.split(times)
        |> map(fn time ->
          t = normalize_time_format(time)

          {:ok, show_time} =
            NaiveDateTime.new(date.year, date.month, date.day, t.hour, t.minute, t.second)

          show_time
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

  def save_markup_file(content) do
    {:ok, file} = File.open("./priv/static/cine_info.html", [:write, :utf8])
    IO.write(file, content)
    File.close(file)
  end

  def get_markup_from_network() do
    url = "http://www.cineplexbd.com/cineplexbd/showtime"
    headers = []
    options = [timeout: 15_000, recv_timeout: 15_000]

    case HTTPoison.get(url, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> 
        save_markup_file body
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404}} -> {:err, "Couldn't find the requested resource"}

      {:error, %HTTPoison.Error{reason: reason}} -> 
        IO.puts reason
        {:err, reason}
    end
  end

  def get_markup() do
    case File.exists? "./priv/static/cine_info.html" do
      true -> File.read("./priv/static/cine_info.html")
      false -> get_markup_from_network()
    end
  end

  def get_cineplex_movie_list() do

    case get_markup() do
      {:ok, body} ->
        parsed_body = Floki.parse(body)
        movie_names = get_movie_names(parsed_body)
        movie_times = get_movie_times(parsed_body)
        movie_dates = get_movie_dates(parsed_body)
        showtimes = merge_movie_date_time(movie_dates, movie_times)
        movie_with_showtimes = merge_movie_with_showtime(movie_names, showtimes)
        movie_names_uniq = get_unique_movies(movie_names)

        movie_data = %{
          :movie_list => movie_names_uniq,
          :movie_with_showtime => movie_with_showtimes
        }

        {:ok, movie_data}

      # movie_showtime_with_date = {:ok, [movie_names, movie_times, movie_dates]}

      {:err, msg} ->
        IO.puts msg
        {:err, msg}
    end
  end

  def prepare_omdb_request_url_from_movie_names(uniq_movie_list) do
    omdb_api_key = Application.get_env(:cinema_api, CinemaApi.CinemaInfoFetcher)[:omdb_api_key]
    omdb_url = "http://www.omdbapi.com/"

    uniq_movie_list
    |> Enum.map(fn movie -> String.replace(movie, " ", "+") end)
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

        {:error, %HTTPoison.Error{id: id, reason: reason}} ->
          %{
            error: true,
            body: nil,
            errMessage: reason
          }
      end
    end)
  end

  def parse_movie_data_from_response(responses) do
    responses
    |> filter(fn response -> !response.error end)
    |> map(fn response -> Poison.decode!(response.body) end)
    |> filter(fn movie -> movie["Response"] == "True" end)
  end

  def create_movie_form_response(responses) do
    responses
    |> map(fn r ->
      %{
        imdb_id: r["imdbID"],
        title: r["Title"],
        year: r["Year"],
        release_date: r["Released"],
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
        media_type: r["Type"],
        box_office: r["BoxOffice"],
        production: r["Production"],
        website: r["Website"]
      }
    end)
  end
end
