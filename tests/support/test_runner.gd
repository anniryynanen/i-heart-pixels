extends Node

var testing: bool = false
var quitting: bool = false
var exit_code: int = 0


func _init() -> void:
    var path: String
    var method: String

    for arg in OS.get_cmdline_user_args():
        if arg == "--tests":
            testing = true

        elif arg.begins_with("--script="):
            path = arg.substr("--script=".length())

        elif arg.begins_with("--method="):
            method = arg.substr("--method=".length())

    if testing:
        await RenderingServer.frame_post_draw

        if path and method:
            run_test_(path, method)
        else:
            launch_tests_("res://tests/example.gd")
            quit_()


func launch_tests_(path: String) -> void:
    if exit_code != 0:
        return

    var script: Resource = load(path).new()

    for method in script.get_method_list():
        if method.name.begins_with("test_"):
            print(path, ": ", method.name)

            var output: Array
            exit_code = OS.execute(OS.get_executable_path(),
                ["--no-header", "--", "--tests",
                    "--script=" + path,
                    "--method=" + method.name],
                output, true)

            for line: String in output:
                print(line)

            if exit_code != 0:
                break


func run_test_(path: String, method: String) -> void:
    var script: Resource = load(path).new()
    var success: bool = script.call(method)

    if not success:
        exit_code = 1

    script.free()
    quit_()


func quit_() -> void:
    quitting = true
    get_tree().root.propagate_notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
