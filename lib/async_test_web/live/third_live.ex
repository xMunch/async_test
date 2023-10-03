defmodule AsyncTestWeb.ThirdLive do
  alias Phoenix.LiveView.AsyncResult
  use AsyncTestWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= if connected?(@socket) do %>
      <.async_result :let={text} assign={@text}>
        <:loading>&gt; &gt; &gt; Loading third live view...</:loading>

        <:failed>&gt; &gt; &gt; Failed to load third live text</:failed>

        <h1><%= text %></h1>
      </.async_result>
    <% else %>
      <p>Connecting third...</p>
    <% end %>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    send(socket.parent_pid, {:subscribe, self()})
    socket = assign(socket, text: AsyncResult.loading(), params: %{})

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_info({:parent_params, params}, socket) do
    socket =
      socket
      |> assign(:params, params)
      |> assign_async([:text], fn ->
        {:ok, %{text: "> > > Third received params"}}
      end)

    {:noreply, socket}
  end

  def handle_info({:listening, _pid}, socket) do
    socket =
      socket
      |> assign_async([:text], fn ->
        {:ok, %{text: "> > > Third attached to Second"}}
      end)

    {:noreply, socket}
  end
end
