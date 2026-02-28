alias SimpleErp.Repo
alias SimpleErp.Catalog.Product

Repo.delete_all(Product)

Repo.insert!(%Product{name: "Keyboard", stock: 10})
Repo.insert!(%Product{name: "Mouse", stock: 5})
Repo.insert!(%Product{name: "Monitor", stock: 2})
Repo.insert!(%Product{name: "Pad", stock: 200})

IO.puts("The seeds file was executed successfully!")
