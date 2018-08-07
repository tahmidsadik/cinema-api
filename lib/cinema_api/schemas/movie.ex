defmodule CinemaApi.Schemas.Movie do
  @moduledoc """
  provides table schema for Movie information
  """
  import Ecto.Changeset
  use Ecto.Schema
  alias CinemaApi.Schemas.Movie

  @type showtime() :: %{
          title: String.t(),
          imdb_id: String.t(),
          showtime: NaiveDateTime.t() | DateTime.t(),
          cinemahall: String.t(),
          movie_id: pos_integer()
        }

  @type movie() :: %{
          imdb_id: String.t(),
          title: String.t(),
          year: String.t(),
          release_date: String.t(),
          runtime: String.t(),
          genre: String.t(),
          director: String.t(),
          actors: String.t(),
          plot: String.t(),
          poster: String.t(),
          language: String.t(),
          country: String.t(),
          awards: String.t(),
          media_type: String.t(),
          box_office: String.t(),
          production: String.t(),
          website: String.t(),
          o_actors: String.t(),
          o_plot: String.t(),
          o_director: String.t(),
          o_release_date: String.t(),
          o_runtime: String.t(),
          o_genre: String.t(),
          showtimes: [NaiveDateTime.t()] | [showtime()]
        }

  schema "movies" do
    has_many(:showtimes, CinemaApi.Schemas.Showtime)
    field(:imdb_id, :string)
    field(:title, :string)
    field(:year, :string)
    field(:release_date, :date)
    field(:runtime, :string)
    field(:genre, :string)
    field(:director, :string)
    field(:actors, :string)
    field(:plot, :string)
    field(:poster, :string)
    field(:language, :string)
    field(:country, :string)
    field(:awards, :string)
    field(:imdb_rating, :string)
    # TODO: Add this ratings later
    # field(:rooten_tomatoes_rating, :string)
    # field(:metacritic_rating, :string)
    field(:media_type, :string)
    field(:box_office, :string)
    field(:production, :string)
    field(:website, :string)
    field(:o_actors, :string)
    field(:o_plot, :string)
    field(:o_director, :string)
    field(:o_release_date, :string)
    field(:o_runtime, :string)
    field(:o_genre, :string)
    timestamps()
  end

  def changeset(%Movie{} = movie, attrs) do
    movie
    |> cast(attrs, [
      :imdb_id,
      :title,
      :year,
      :release_date,
      :runtime,
      :genre,
      :director,
      :plot,
      :poster,
      :country,
      :language,
      :awards,
      :imdb_rating,
      :media_type,
      :box_office,
      :production,
      :website,
      :actors,
      :o_actors,
      :o_director,
      :o_genre,
      :o_plot,
      :o_release_date,
      :o_runtime
    ])
    |> unique_constraint(:title)
    |> unique_constraint(:imdb_id)
    |> cast_assoc(:showtimes, required: true)
  end
end
