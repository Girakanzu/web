defmodule Entice.Web.MovementChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Logic.Area
  alias Entice.Logic.Movement, as: Move
  alias Entice.Web.Client
  alias Entice.Web.Token
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  def join("movement:" <> map, %{"client_id" => client_id, "entity_token" => token}, socket) do
    {:ok, ^token, :entity, %{area: map_mod, entity_id: entity_id, char: char}} = Token.get_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))

    :ok = Move.init(entity_id)

    socket = socket
      |> set_area(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    socket |> reply("join:ok", %{})
    {:ok, socket}
  end


  def handle_in("update:pos", %{"pos" => %{"x" => x, "y" => y} = pos}, socket) do
    Entity.put_attribute(socket |> entity_id, %Position{pos: %Coord{x: x, y: y}})
    broadcast!(socket, "update:pos", %{entity: socket |> entity_id, pos: pos})

    {:ok, socket}
  end


  def handle_in("update:goal", %{"goal" => %{"x" => x, "y" => y} = goal, "plane" => plane}, socket) do
    Move.change_goal(socket |> entity_id, %Coord{x: x, y: y}, plane)
    broadcast!(socket, "update:goal", %{entity: socket |> entity_id, goal: goal, plane: plane})

    {:ok, socket}
  end


   def handle_in("update:speed", %{"movetype" => mtype}, socket) when mtype in 0..10 do
    Move.change_move_type(socket |> entity_id, mtype)
    broadcast!(socket, "update:movetype", %{entity: socket |> entity_id, movetype: mtype})

    {:ok, socket}
  end


  def handle_in("update:speed", %{"speed" => speed}, socket) when speed in -1..2 do
    Move.change_speed(socket |> entity_id, speed)
    broadcast!(socket, "update:speed", %{entity: socket |> entity_id, speed: speed})

    {:ok, socket}
  end


  def leave(_msg, socket) do
    Move.remove(socket |> entity_id)
    {:ok, socket}
  end
end

