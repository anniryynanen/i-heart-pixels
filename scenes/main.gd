extends Control

var toolbar_orig_y_: float
var notification_tween_: Tween


func _init() -> void:
    # https://github.com/godotengine/godot/issues/93014
    if OS.has_feature("linux"):
        Engine.max_fps = 60


func _enter_tree() -> void:
    Settings.load_settings()

    toolbar_orig_y_ = %Toolbar.position.y

    Globals.image_changed.connect(_on_image_changed)
    Globals.unsaved_changes_changed.connect(func(_u: bool) -> void: update_title_())
    Globals.current_path_changed.connect(func(_p: String) -> void: update_title_())
    Globals.app_scale_changed.connect(_on_app_scale_changed)

    Globals.show_notification.connect(show_notification_)

    get_tree().auto_accept_quit = false
    get_tree().node_added.connect(_on_node_added)


func _ready() -> void:
    apply_settings_()
    update_title_()
    Globals.tool = Tool.PEN

    for arg in OS.get_cmdline_user_args():
        if not arg.begins_with("-"):
            Globals.load_image(arg)
            break


func _notification(what: int) -> void:
    # The app is quitting
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        if Globals.image.unsaved_changes and not TestRunner.quitting:
            $UnsavedChangesPopup.popup_centered()
        else:
            quit_()


func _on_node_added(node: Node) -> void:
    if node is Control:
        var control: Control = node as Control

        if control is LineEdit:
            var line: LineEdit = control as LineEdit
            line.caret_blink = true

        if control.focus_mode != Control.FOCUS_NONE:
            # Don't mind popup contents
            var parent: Node = control.get_parent()
            while parent != self:
                if parent is Window:
                    return
                parent = parent.get_parent()

            # Can't have focusable nodes in the main view, or Space can
            # activate them in addition to color sampler
            push_error("Focusable node added to main view: ", control)


func _on_resized() -> void:
    if Globals.loading:
        return

    if get_window().mode == Window.Mode.MODE_WINDOWED:
        Settings.set_value("window", "x", get_window().position.x)
        Settings.set_value("window", "y", get_window().position.y)
        Settings.set_value("window", "width", get_window().size.x)
        Settings.set_value("window", "height", get_window().size.y)

    Settings.set_value("window", "mode", get_window().mode)


func _on_image_changed(image: IHP) -> void:
    %ImageSize.text = "%sx%s" % [image.size.x, image.size.y]


func _on_main_split_dragged(offset: int) -> void:
    Settings.set_value("panels", "right_width", roundi(-offset / Globals.app_scale))


func _on_right_split_dragged(offset: int) -> void:
    Settings.set_value("panels", "right_height", roundi(-offset / Globals.app_scale))


func _on_github_pressed() -> void:
    OS.shell_open(Globals.GITHUB_URL)


func _on_app_scale_changed(app_scale: float) -> void:
    %Toolbar.position.y = toolbar_orig_y_ * Globals.app_scale
    %Toolbar.reset_size.call_deferred()

    %MainSplit.split_offset = roundi(
        -Settings.get_value("panels", "right_width", 200.0) * Globals.app_scale)

    %RightSplit.split_offset = roundi(
        -Settings.get_value("panels", "right_height", -200.0) * Globals.app_scale)


func _on_unsaved_changes_popup_save() -> void:
    %MainMenu.save(Globals.current_path, quit_)


func apply_settings_() -> void:
    Globals.apply_settings()
    AppScaler.start.call_deferred()

    await RenderingServer.frame_post_draw

    if OS.has_feature("web"):
        %GitHubContainer.visible = true
        %GitHub.tooltip_text = Globals.GITHUB_URL
    else:
        if Settings.has_value("window", "width"):
            get_window().size.x = Settings.get_value("window", "width")
            get_window().size.y = Settings.get_value("window", "height")

        if Settings.has_value("window", "x"):
            get_window().position.x = Settings.get_value("window", "x")
            get_window().position.y = Settings.get_value("window", "y")

        get_window().mode = Settings.get_value("window", "mode", Window.Mode.MODE_WINDOWED)

    Globals.loading = false


func update_title_() -> void:
    if OS.has_feature("web"):
        get_window().title = ProjectSettings.get_setting("application/config/name")
    else:
        var title: String = ""

        if Globals.current_path:
            title += Globals.current_path.get_file()
        else:
            title += "[not saved]"

        if Globals.image.unsaved_changes:
            title += "*"

        title += " - " + ProjectSettings.get_setting("application/config/name")
        get_window().title = title


func show_notification_(message: String) -> void:
    if notification_tween_ and notification_tween_.is_running():
        notification_tween_.stop()

    %Notification.text = message
    %Notification.reset_size()
    %Notification.position.x = size.x / 2.0 - %Notification.size.x / 2.0
    %Notification.position.y = size.y
    %Notification.visible = true

    var distance: float = %Notification.size.y * 1.7

    notification_tween_ = create_tween()
    notification_tween_.tween_property(%Notification, "position", Vector2.UP * distance, 0.12) \
        .as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

    notification_tween_.tween_interval(1.2)
    notification_tween_.tween_property(%Notification, "position", Vector2.DOWN * distance, 0.12) \
        .as_relative().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

    notification_tween_.tween_callback(func() -> void: %Notification.visible = false)


func quit_() -> void:
    if get_window().mode == Window.Mode.MODE_WINDOWED:
        Settings.set_value("window", "x", get_window().position.x)
        Settings.set_value("window", "y", get_window().position.y)

    Settings.save_settings()
    get_tree().quit(TestRunner.exit_code if TestRunner.quitting else 0)
