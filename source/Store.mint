// Original code: https://github.com/mint-lang/mint-example-todo
// Updated to use generated API client

// TodoItem for internal use - unwraps Maybe fields from API types
type TodoItem {
  text : String,
  completed : Bool,
  id : Number
}

// Helper to convert API Todo type (with Maybe fields) to TodoItem
module TodoItemConverter {
  fun fromApiTodo (todo : Todo) : Maybe(TodoItem) {
    case {todo.text, todo.completed, todo.id} {
      {Maybe.Just(text), Maybe.Just(completed), Maybe.Just(id)} =>
        Maybe.Just({ text: text, completed: completed, id: id })

      => Maybe.Nothing
    }
  }
}

store Todos {
  state items : Array(TodoItem) = []
  state error : String = ""

  fun add (text : String) : Promise(Void) {
    let body =
      { text: Maybe.Just(text) }

    let result =
      await TodoApi.postTodos(body)

    case result {
      Ok(response) =>
        {
          // Reload all items after adding
          await load()
        }

      Err(error) =>
        {
          await next { error: "Failed to add todo" }
        }
    }
  }

  fun remove (item : TodoItem) : Promise(Void) {
    let result =
      await TodoApi.deleteTodosId(Number.toString(item.id))

    case result {
      Ok(success) =>
        {
          let updatedItems =
            Array.reject(items, (todo : TodoItem) : Bool { todo.id == item.id })

          await next { items: updatedItems }
        }

      Err(error) =>
        {
          await next { error: "Failed to remove todo" }
        }
    }
  }

  fun toggle (item : TodoItem) : Promise(Void) {
    let updatedTodo =
      {
        text: Maybe.Just(item.text),
        completed: Maybe.Just(!item.completed),
        id: Maybe.Just(item.id)
      }

    let result =
      await TodoApi.putTodosId(Number.toString(item.id), updatedTodo)

    case result {
      Ok(response) =>
        {
          let updatedItems =
            Array.map(items,
              (todo : TodoItem) : TodoItem {
                if todo.id == item.id {
                  { item | completed: !item.completed }
                } else {
                  todo
                }
              })

          await next { items: updatedItems }
        }

      Err(error) =>
        {
          await next { error: "Failed to toggle todo" }
        }
    }
  }

  fun load : Promise(Void) {
    let result =
      await TodoApi.getTodos()

    case result {
      Ok(apiTodos) =>
        {
          // Convert API Todo types (with Maybe fields) to TodoItem
          let todoItems =
            apiTodos
            |> Array.map(TodoItemConverter.fromApiTodo)
            |> Array.compact()

          await next { items: todoItems, error: "" }
        }

      Err(error) =>
        {
          await next { error: "Failed to load todos", items: [] }
        }
    }
  }
}