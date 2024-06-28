var ihp = ihp || {};

ihp.input = document.createElement("input");
ihp.input.type = "file";
ihp.input.accept = ".ihp,.png,.jpg,.jpeg";

ihp.input.onchange = () => {
    const name = ihp.input.files[0].name;
    const reader = new FileReader();
    reader.onload = (e) => ihp.on_opened(name, e.target.result);
    reader.readAsDataURL(ihp.input.files[0]);
};

ihp.open_file = (on_opened) => {
    ihp.on_opened = on_opened;
    ihp.input.click();
};
