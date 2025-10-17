type Filter {
  All
  Active
  Completed
}

type Status {
  Loading
  Loaded
  Failed(String)
}

component Main {
  state todos : Array(Todo) = []
  state status : Status = Status.Loaded
  state newTodoText : String = ""
  state filter : Filter = Filter.All

  style root {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
    font-size: 14px;
    line-height: 1.4em;
    background: #f5f5f5;
    color: #4d4d4d;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 20px;
  }

  style todoapp {
    background: #fff;
    box-shadow: 0 2px 4px 0 rgba(0, 0, 0, 0.2), 0 25px 50px 0 rgba(0, 0, 0, 0.1);
    width: 550px;
  }

  style header {
    padding: 20px 15px;
  }

  style title {
    font-size: 80px;
    font-weight: 200;
    text-align: center;
    color: #b83f45;
    margin: 0;
    text-rendering: optimizeLegibility;
  }

  style newTodo {
    width: 100%;
    font-size: 24px;
    font-family: inherit;
    font-weight: inherit;
    line-height: 1.4em;
    border: none;
    color: inherit;
    padding: 16px 16px 16px 60px;
    border: none;
    background: rgba(0, 0, 0, 0.003);
    box-shadow: inset 0 -2px 1px rgba(0,0,0,0.03);
    box-sizing: border-box;

    &::placeholder {
      font-style: italic;
      font-weight: 300;
      color: rgba(0, 0, 0, 0.4);
    }

    &:focus {
      outline: none;
    }
  }

  style main {
    border-top: 1px solid #e6e6e6;
  }

  style todoList {
    margin: 0;
    padding: 0;
    list-style: none;
  }

  style todoItem {
    position: relative;
    font-size: 24px;
    border-bottom: 1px solid #ededed;
    display: flex;
    align-items: center;

    &:last-child {
      border-bottom: none;
    }
  }

  style todoItemCompleted {
    color: #d9d9d9;
    text-decoration: line-through;
  }

  style toggle {
    width: 40px;
    height: 40px;
    text-align: center;
    border: none;
    background: none;
    cursor: pointer;
    appearance: none;
    margin: 11px 0 11px 15px;
    position: relative;

    &:before {
      content: "○";
      font-size: 30px;
      color: #e6e6e6;
      line-height: 40px;
    }
  }

  style toggleChecked {
    &:before {
      content: "✓";
      font-size: 20px;
      color: #5dc2af;
      line-height: 40px;
      font-weight: bold;
    }
  }

  style label {
    word-break: break-all;
    padding: 15px 15px 15px 15px;
    display: block;
    line-height: 1.2;
    transition: color 0.4s;
    flex: 1;
  }

  style destroyButton {
    position: absolute;
    right: 10px;
    width: 40px;
    height: 40px;
    font-size: 30px;
    color: #cc9a9a;
    margin: auto 0;
    transition: color 0.2s ease-out;
    background: none;
    border: none;
    cursor: pointer;
    opacity: 0;

    &:hover {
      color: #af5b5e;
    }
  }

  style todoItemHover {
    .destroyButton {
      opacity: 1;
    }
  }

  style footer {
    color: #777;
    padding: 10px 15px;
    height: 20px;
    text-align: center;
    border-top: 1px solid #e6e6e6;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  style todoCount {
    text-align: left;
    
    strong {
      font-weight: 300;
    }
  }

  style filters {
    margin: 0;
    padding: 0;
    list-style: none;
    display: flex;
    gap: 5px;
  }

  style filterButton {
    color: inherit;
    padding: 3px 7px;
    text-decoration: none;
    border: 1px solid transparent;
    border-radius: 3px;
    background: none;
    cursor: pointer;
    font-size: 14px;

    &:hover {
      border-color: rgba(175, 47, 47, 0.1);
    }
  }

  style filterSelected {
    border-color: rgba(175, 47, 47, 0.2);
  }

  style clearCompleted {
    color: inherit;
    border: none;
    background: none;
    cursor: pointer;
    position: relative;
    font-size: 14px;

    &:hover {
      text-decoration: underline;
    }
  }

  style info {
    margin: 65px auto 0;
    color: #bfbfbf;
    font-size: 10px;
    text-shadow: 0 1px 0 rgba(255, 255, 255, 0.5);
    text-align: center;
    
    p {
      line-height: 1;
    }
  }

  style loading {
    text-align: center;
    padding: 20px;
    color: #777;
    font-size: 16px;
  }

  style error {
    text-align: center;
    padding: 20px;
    color: #af5b5e;
    font-size: 14px;
  }

  fun componentDidMount : Promise(Void) {
    loadTodos()
  }

  fun loadTodos : Promise(Void) {
    next { status: Status.Loading }
    
    let response = await TodoApi.getTodos()
    
    case response {
      Result.Ok(fetchedTodos) => 
        next { 
          todos: fetchedTodos,
          status: Status.Loaded 
        }
      Result.Err(APIError.HttpError(error)) => 
        next { status: Status.Failed("Network error: Could not connect to server") }
      Result.Err(APIError.JsonParseError) => 
        next { status: Status.Failed("Invalid response from server") }
      Result.Err(APIError.DecodeError(error)) => 
        next { status: Status.Failed("Could not parse server response") }
    }
  }

  fun handleNewTodoInput(event : Html.Event) : Promise(Void) {
    next { newTodoText: Dom.getValue(event.target) }
  }

  fun handleNewTodoKeyDown(event : Html.Event) : Promise(Void) {
    if event.keyCode == 13 {
      createTodo()
    } else {
      Promise.never()
    }
  }

  fun createTodo : Promise(Void) {
    if String.isEmpty(String.trim(newTodoText)) {
      Promise.never()
    } else {
      let body = { text: String.trim(newTodoText) }
      let response = await TodoApi.postTodos(body)
      
      case response {
        Result.Ok(todo) => {
          next { newTodoText: "" }
          loadTodos()
        }
        Result.Err(error) => 
          next { status: Status.Failed("Failed to create todo") }
      }
    }
  }

  fun deleteTodo(id : Number) : Promise(Void) {
    let response = await TodoApi.deleteTodosId(Number.toString(id))
    
    case response {
      Result.Ok(success) => loadTodos()
      Result.Err(error) => 
        next { status: Status.Failed("Failed to delete todo") }
    }
  }

  fun toggleTodo(todo : Todo) : Promise(Void) {
    // Since the backend doesn't support updates, we toggle locally
    // The change won't persist on reload
    let updatedTodos = 
      Array.map(todos, (t : Todo) {
        if t.id == todo.id {
          { 
            id: t.id,
            text: t.text,
            completed: !t.completed
          }
        } else {
          t
        }
      })
    
    next { todos: updatedTodos }
  }

  fun clearCompleted : Promise(Void) {
    // TODO: Implement batch deletion when Mint supports it better
    // For now, users can delete completed items one by one
    Promise.never()
  }

  fun setFilter(newFilter : Filter) : Promise(Void) {
    next { filter: newFilter }
  }

  fun getFilteredTodos : Array(Todo) {
    case filter {
      Filter.All => todos
      Filter.Active => Array.select(todos, (todo : Todo) { !todo.completed })
      Filter.Completed => Array.select(todos, (todo : Todo) { todo.completed })
    }
  }

  fun getActiveCount : Number {
    Array.size(Array.select(todos, (todo : Todo) { !todo.completed }))
  }

  fun getCompletedCount : Number {
    Array.size(Array.select(todos, (todo : Todo) { todo.completed }))
  }

  fun renderTodo(todo : Todo) : Html {
    if todo.completed {
      <li::todoItem::todoItemCompleted>
        <button::toggle::toggleChecked
          onClick={(event : Html.Event) { toggleTodo(todo) }}/>
        <div::label>
          todo.text
        </div>
        <button::destroyButton 
          onClick={(event : Html.Event) { deleteTodo(todo.id) }}>
          "×"
        </button>
      </li>
    } else {
      <li::todoItem>
        <button::toggle
          onClick={(event : Html.Event) { toggleTodo(todo) }}/>
        <div::label>
          todo.text
        </div>
        <button::destroyButton 
          onClick={(event : Html.Event) { deleteTodo(todo.id) }}>
          "×"
        </button>
      </li>
    }
  }

  fun render : Html {
    let filteredTodos = getFilteredTodos()
    let activeCount = getActiveCount()
    let completedCount = getCompletedCount()
    let hasTodos = Array.size(todos) > 0

    <div::root>
      <div::todoapp>
        <header::header>
          <h1::title>"todos"</h1>
          <input::newTodo
            type="text"
            placeholder="What needs to be done?"
            value={newTodoText}
            onChange={handleNewTodoInput}
            onKeyDown={handleNewTodoKeyDown}/>
        </header>

        case status {
          Status.Loading => 
            <div::loading>"Loading todos..."</div>
          
          Status.Failed(message) => 
            <div::error>
              "⚠ "
              message
            </div>
          
          Status.Loaded =>
            if hasTodos {
              <div>
                <section::main>
                  <ul::todoList>
                    for todo of filteredTodos {
                      renderTodo(todo)
                    }
                  </ul>
                </section>

                <footer::footer>
                  <span::todoCount>
                    <strong>
                      Number.toString(activeCount)
                    </strong>
                    if activeCount == 1 {
                      " item left"
                    } else {
                      " items left"
                    }
                  </span>

                  <ul::filters>
                    <li>
                      if filter == Filter.All {
                        <button::filterButton::filterSelected
                          onClick={(event : Html.Event) { setFilter(Filter.All) }}>
                          "All"
                        </button>
                      } else {
                        <button::filterButton
                          onClick={(event : Html.Event) { setFilter(Filter.All) }}>
                          "All"
                        </button>
                      }
                    </li>
                    <li>
                      if filter == Filter.Active {
                        <button::filterButton::filterSelected
                          onClick={(event : Html.Event) { setFilter(Filter.Active) }}>
                          "Active"
                        </button>
                      } else {
                        <button::filterButton
                          onClick={(event : Html.Event) { setFilter(Filter.Active) }}>
                          "Active"
                        </button>
                      }
                    </li>
                    <li>
                      if filter == Filter.Completed {
                        <button::filterButton::filterSelected
                          onClick={(event : Html.Event) { setFilter(Filter.Completed) }}>
                          "Completed"
                        </button>
                      } else {
                        <button::filterButton
                          onClick={(event : Html.Event) { setFilter(Filter.Completed) }}>
                          "Completed"
                        </button>
                      }
                    </li>
                  </ul>

                  <div/>
                </footer>
              </div>
            } else {
              <div/>
            }
        }
      </div>

      <footer::info>
        <p>"Note: Completed status is local only (backend doesn't support updates)"</p>
        <p>"Created with Mint"</p>
      </footer>
    </div>
  }
}
