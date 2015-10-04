defmodule Entice.Web.ClientTest do
  use ExUnit.Case
  alias Entice.Skills
  alias Entice.Web.Character
  alias Entice.Web.Client

  test "default accounts" do
    assert {:ok, _id} = Client.log_in("root@entice.ps", "root")
  end

  test "default character" do
    assert {:ok, id} = Client.log_in("root@entice.ps", "root")
    assert {:ok, char} = Client.get_char(id, "root@entice.ps 1")
    assert Skills.max_unlocked_skills == :erlang.list_to_integer(char.available_skills |> String.to_char_list, 16)
  end

  test "account updating while getting" do
    assert {:ok, id} = Client.log_in("root@entice.ps", "root")
    assert {:ok, acc} = Client.get_account(id)
    assert {:ok, char} = Entice.Web.Repo.insert(%Character{name: "Blubb Test Blubb", account_id: acc.id})
    assert {:ok, ^char} = Client.get_char(id, char.name)
  end
end
