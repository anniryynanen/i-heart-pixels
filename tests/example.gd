extends Object


func test_something() -> bool:
    print("testing testing")
    return true


func test_another_thing() -> bool:
    push_error("error message")
    return false


func test_something_else() -> bool:
    print("something else")
    return true
