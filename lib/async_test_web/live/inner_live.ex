defmodule AsyncTestWeb.InnerLive do
  use AsyncTestWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= if connected?(@socket) do %>
      <%= if Map.get(assigns, :inner_text) do %>
        <.async_result :let={inner_text} assign={@inner_text}>
          <:loading>&gt; Loading inner live view...</:loading>

          <:failed>&gt; Failed to load inner_text</:failed>

          <h1>
            <%= inner_text %>
          </h1>
        </.async_result>
      <% end %>

      <%= live_render(
        @socket,
        AsyncTestWeb.SecondaryLive,
        id: :secondary
      ) %>
    <% else %>
      <p>Connecting inner...</p>
    <% end %>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      socket =
        assign_async(socket, [:inner_text], fn ->
          {:ok, %{inner_text: "> Inner attached to parent"}}
        end)

      {:ok, socket}
    else
      {:ok, socket}
    end
  end
end
