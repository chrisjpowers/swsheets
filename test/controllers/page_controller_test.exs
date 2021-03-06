defmodule EdgeBuilder.Controllers.PageControllerTest do
  use EdgeBuilder.ControllerTest

  alias Factories.UserFactory
  alias Factories.CharacterFactory

  describe "index" do
    it "shows a list of characters" do
      user = UserFactory.default_user

      characters = [
        CharacterFactory.create_character(name: "Frank", user_id: user.id),
        CharacterFactory.create_character(name: "Boba Fett", user_id: user.id)
      ]

      conn = request(:get, "/")

      for character <- characters do
        assert String.contains?(conn.resp_body, character.name)
      end
    end

    it "shows a list of users who have contributed to the project in order of most recent contribution across types" do
      UserFactory.create_user(username: "third") |> UserFactory.set_contributions(
        bug_reported_at:   %Ecto.DateTime{day: 5, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
        pull_requested_at: %Ecto.DateTime{day: 5, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
      )

      UserFactory.create_user(username: "second") |> UserFactory.set_contributions(
        bug_reported_at:   %Ecto.DateTime{day: 7, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
        pull_requested_at: %Ecto.DateTime{day: 2, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
      )

      UserFactory.create_user(username: "first") |> UserFactory.set_contributions(
        pull_requested_at: %Ecto.DateTime{day: 8, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
      )

      UserFactory.create_user(username: "nocontributions")

      conn = request(:get, "/")

      assert String.match?(conn.resp_body, ~r/first.*second.*third/s)
      assert !String.contains?(conn.resp_body, "nocontributions")
    end

    it "shows a message if your password has just been reset" do
      conn = request(:get, "/", %{}, fn(c) -> Plug.Conn.put_session(c, "phoenix_flash", %{"has_reset_password" => true}) end)

      assert String.contains?(conn.resp_body, "Your password has been reset and you are now logged in. Welcome back!")
    end

    it "shows no message if your password has not just been reset" do
      conn = request(:get, "/")

      assert !String.contains?(conn.resp_body, "Your password has been reset and you are now logged in. Welcome back!")
    end
  end

  describe "thanks" do
    it "shows a full list of contributors" do
      UserFactory.create_user(username: "mark") |> UserFactory.set_contributions(
        bug_reported_at:   %Ecto.DateTime{day: 5, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
      )

      UserFactory.create_user(username: "john") |> UserFactory.set_contributions(
        bug_reported_at:   %Ecto.DateTime{day: 7, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
        pull_requested_at: %Ecto.DateTime{day: 2, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
      )

      UserFactory.create_user(username: "luke") |> UserFactory.set_contributions(
        pull_requested_at: %Ecto.DateTime{day: 8, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
      )

      conn = request(:get, "/thanks")

      assert String.contains?(conn.resp_body, "mark")
      assert String.contains?(conn.resp_body, "john")
      assert String.contains?(conn.resp_body, "luke")
    end
  end
end
