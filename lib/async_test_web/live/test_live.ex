defmodule AsyncTestWeb.TestLive do
  use AsyncTestWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= if connected?(@socket) do %>
      <div id="parent">
        <.async_result :let={parent_text} assign={@parent_text}>
          <:loading>Loading parent live view...</:loading>

          <:failed>Failed to load parent_text live text</:failed>

          <h1><%= parent_text %></h1>
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
      |> assign_async([:parent_text], fn ->
        {:ok, %{parent_text: "Parent"}}
      end)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    if connected?(socket) do
      {:ok, assign(socket, %{params: params})}
    else
      {:ok, socket}
    end
  end
end
