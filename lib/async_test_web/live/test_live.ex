defmodule AsyncTestWeb.TestLive do
  use AsyncTestWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= if connected?(@socket) do %>
      <div id="parent">
        <.async_result :let={text} assign={@text}>
          <:loading>Loading parent live view...</:loading>

          <:failed>Failed to load parent live text</:failed>

          <h1><%= text %></h1>
        </.async_result>

        <%= live_render(
          @socket,
          AsyncTestWeb.InnerLive,
          id: :inner,
          params: @params
        ) %>
      </div>
    <% else %>
      <p>Connecting...</p>
    <% end %>
    """
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> assign(%{params: params})
      |> assign_async([:text], fn ->
        {:ok, %{text: "Parent"}}
      end)

    socket.assigns
    |> Map.get(:subscriptions, [])
    |> Enum.each(fn pid ->
      send(pid, {:parent_params, params})
    end)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    if connected?(socket) do
      socket =
        socket
        |> assign(%{params: params})
        |> assign_async([:text], fn ->
          {:ok, %{text: "Parent"}}
        end)

      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:subscribe, pid}, socket) do
    Process.monitor(pid)
    subscriptions = Map.get(socket.assigns, :subscriptions, [])
    subscriptions = [pid | subscriptions]

    send(pid, {:listening, self()})

    {:noreply, assign(socket, subscriptions: subscriptions)}
  end
end
