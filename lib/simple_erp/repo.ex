defmodule SimpleErp.Repo do
  use Ecto.Repo,
    otp_app: :simple_erp,
    adapter: Ecto.Adapters.Postgres
end
