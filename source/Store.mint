// Original code: https://github.com/mint-lang/mint-example-todo
// Updated to use generated API client

store Todos {
  state items : Array(Todo) = []
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

  fun remove (item : Todo) : Promise(Void) {
    case item.id {
      Maybe.Just(id) =>
        {
          let result =
            await TodoApi.deleteTodosId(Number.toString(id))

          case result {
            Ok(success) =>
              {
                let updatedItems =
                  Array.reject(items, (todo : Todo) : Bool { todo.id == item.id })

                await next { items: updatedItems }
              }

            Err(error) =>
              {
                await next { error: "Failed to remove todo" }
              }
          }
        }

      Maybe.Nothing =>
        {
          await next { error: "Cannot remove todo without ID" }
        }
    }
  }

  fun toggle (item : Todo) : Promise(Void) {
    case {item.id, item.completed} {
      {Maybe.Just(id), Maybe.Just(completed)} =>
        {
          let updatedTodo =
            { item | completed: Maybe.Just(!completed) }

          let result =
            await TodoApi.putTodosId(Number.toString(id), updatedTodo)

          case result {
            Ok(response) =>
              {
                let updatedItems =
                  Array.map(items,
                    (todo : Todo) : Todo {
                      if todo.id == item.id {
                        { item | completed: Maybe.Just(!completed) }
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

      =>
        {
          await next { error: "Cannot toggle todo without ID or completed status" }
        }
    }
  }

  fun load : Promise(Void) {
    let result =
      await TodoApi.getTodos()

    case result {
      Ok(todos) =>
        {
          await next { items: todos, error: "" }
        }

      Err(error) =>
        {
          await next { error: "Failed to load todos", items: [] }
        }
    }
  }
}