extends Node

const TESTING: bool = false
const ONLY_PATH: String = ""
const ONLY_METHOD: String = ""

var quitting: bool = false
var exit_code: int = 0

var ihps_: Dictionary
var pngs_: Dictionary


func _init() -> void:
    var path: String
    var method: String

    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--script="):
            path = arg.substr("--script=".length())

        elif arg.begins_with("--method="):
            method = arg.substr("--method=".length())

    if TESTING:
        await RenderingServer.frame_post_draw

        if ONLY_PATH != "" and ONLY_METHOD != "":
            await run_test_(ONLY_PATH, ONLY_METHOD)
            print("OK" if exit_code == 0 else "TEST FAILED")
        elif path and method:
            await run_test_(path, method)
        else:
            launch_tests_("res://tests/test_main_menu.gd")
            launch_tests_("res://tests/test_tools.gd")
            launch_tests_("res://tests/test_resizing.gd")
            launch_tests_("res://tests/test_color_picker.gd")

            print("ALL TESTS OK" if exit_code == 0 else "TEST FAILED")
            quit_()


func launch_tests_(path: String) -> void:
    if exit_code != 0:
        return

    var script: Node = load(path).new()

    for method in script.get_method_list():
        if method.name.begins_with("should_"):
            print(path, ": ", method.name)

            var output: Array
            exit_code = OS.execute(OS.get_executable_path(),
                ["--no-header", "--",
                    "--script=" + path,
                    "--method=" + method.name],
                output, true)

            if output.size() > 1 or output[0] != "":
                for line: String in output:
                    print(line.replace("\n", ""))

            if exit_code != 0:
                break


func run_test_(path: String, method: String) -> void:
    var script: Node = load(path).new()
    add_child(script)
    var success: bool = await script.call(method)
    remove_child(script)

    if not success:
        exit_code = 1

    script.queue_free()
    quit_()


func quit_() -> void:
    quitting = true
    get_tree().root.propagate_notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)


func open_ihp(path: String) -> MockFileAccess:
    if path not in ihps_:
        ihps_[path] = MockFileAccess.new()
    return ihps_[path]


func save_png(path: String, image: Image) -> void:
    pngs_[path] = image.duplicate()


func load_image(path: String) -> Image:
    if path.ends_with(".png"):
        return pngs_[path]
    elif path.ends_with(".jpg"):
        return Image.create(16, 16, false, IHP.FORMAT)
    return null
