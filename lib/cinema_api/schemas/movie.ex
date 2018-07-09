defmodule CinemaApi.Schemas.Movie do
  @moduledoc """
  provides table schema for Movie information
  """
  import Ecto.Changeset
  use Ecto.Schema

  schema "movies" do
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
    timestamps()
  end

  def changeset(movie, attrs) do
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
      :website
    ])
  end
end
