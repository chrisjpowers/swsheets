defmodule EdgeBuilder.CharacterView do
  use EdgeBuilder.Web, :view

  alias EdgeBuilder.Repo
  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Models.Characteristic

  def image_or_default(character) do
    get_field(character, :portrait_url) || "/images/250x250.gif"
  end

  def lookup_skill(nil), do: nil
  def lookup_skill(skill_id) do
    Repo.get(BaseSkill, skill_id).name
  end

  def options_for_attack_skills(selected_skill_id) do
    Enum.map(BaseSkill.attack_skills, fn s ->
      selection = if s.id == selected_skill_id, do: "selected"
      system = unless is_nil(s.system), do: "data-system=#{s.system}"

      "<option value='#{s.id}' #{selection} #{system}>#{s.name}</option>"
    end) |> raw
  end

  def skill_display_name(skill) do
    "#{skill.name} (#{Characteristic.shorthand_for(skill.characteristic)})"
  end

  def skills_in_system(character_skills, system) do
    Enum.filter(character_skills, fn(cs) ->
      is_nil(cs.system) || cs.system == system
    end)
  end

  def selected_characteristic(skill) do
    if Enum.member?(skill.characteristics, skill.characteristic) do
      skill.characteristic
    else
      Enum.at(skill.characteristics, 0)
    end
  end

  def is_characteristic_toggle_displayed?([_]), do: false
  def is_characteristic_toggle_displayed?(_), do: true

  def species_by_system do
    [
      {"Edge of the Empire", [
        "Aqualish (Aquala)", "Aqualish (Quara)", "Aqualish (Ualaq)",
        "Arcona", "Bothan", "Chevin", "Chiss", "Drall",
        "Droid", "Duros", "Gand", "Gank", "Human", "Human (Corellian)",
        "Hutt", "Klatooinian", "Rodian", "Selonian", "Toydarian",
        "Twi'lek", "Weequay", "Wookiee"
      ]},
      {"Age of the Republic", [
        "Caamasi", "Chadra-Fan", "Dressellian", "Droid",
        "Duros", "Gossam", "Gran", "Human", "Ithorian",
        "Mon Calamari", "Neimoidian", "Sullustan", "Xexto"
      ]},
      {"Force and Destiny", [
        "Cerean", "Kel Dor", "Mirialan", "Nautolan", "Togruta", "Zabrak"
      ]}
    ]
  end

  def careers_by_system do
    [
      {"Edge of the Empire", ["Bounty Hunter","Colonist","Explorer","Hired Gun","Smuggler","Technician"]},
      {"Age of the Republic", ["Ace","Commander","Diplomat","Engineer","Soldier","Spy"]},
      {"Force and Destiny", ["Consular","Guardian","Sentinel","Mystic", "Seeker","Warrior"]}
    ]
  end
end
