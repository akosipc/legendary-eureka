defmodule ChatApp.MessageController do
  use ChatApp.Web, :controller

  alias ChatApp.Message

  plug :scrub_params, "message" when action in [:create]

  def index(conn, _params) do
    messages = Repo.all from m in Message, order_by: [desc: m.inserted_at]
    last_username = get_session(conn, :username)
    IO.inspect last_username
    changeset = Message.changeset(%Message{username: last_username})

    render conn, "index.html", messages: messages, changeset: changeset
  end

  def create(conn, %{"message" => message_params}) do
    changeset = Message.changeset(%Message{}, message_params)

    case Repo.insert(changeset) do
      {:ok, message} ->
        put_session(conn, :username, message.username)
        |> put_flash(:info, "Message sent.")
        |> redirect(to: message_path(conn, :index))
      {:error, changeset} ->
        messages = Repo.all from m in Message, order_by: [desc: m.inserted_at]
        conn
        |> put_flash(:error, "There were some errors encountered.")
        |> render("index.html", changeset: changeset, messages: messages)
    end
  end

end
