defmodule EdgeBuilder.Models.BaseSkill do
  use EdgeBuilder.Web, :model

  schema "base_skills" do
    field :name, :string
    field :characteristic, :string
    field :display_order, :integer
    field :is_attack_skill, :boolean, default: false
    field :system, Ecto.Types.Enumeration
  end

  def changeset(params) do
    %EdgeBuilder.Models.BaseSkill{}
    |> cast(params, [], ~w(name characteristic display_order is_attack_skill system))
  end

  def all do
    Repo.all(
      from bs in __MODULE__,
        order_by: :display_order
    )
  end

  def by_name(name) do
    Repo.one(
      from bs in __MODULE__,
        where: bs.name == ^name
    )
  end

  def attack_skills do
    Repo.all(
      from bs in __MODULE__,
        where: bs.is_attack_skill == true,
        order_by: :display_order
    )
  end
end
