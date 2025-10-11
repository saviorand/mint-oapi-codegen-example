component Main {
  fun loadUser : Promise(Void) {
    let response = await BlogApi.getUser(1)
    
    case response {
      Result.Ok(user) => {
        Debug.log(user.username)
        void
      }
      Result.Err(error) => {
        Debug.log("Error loading user:")
        Debug.log(error)
        void
      }
    }
  }
  
  fun render : Html {
    <div>
      <button onClick={loadUser}>
        "Load User"
      </button>
    </div>
  }
}