export function alert_js(message) {
  alert(message);
}

export function alert_js_object_data(message) {
  alert(message.data);
}

export function get_data_as_string_js(some_object) {
  return some_object.data;
}

export function get_data_field_js(some_object, field) {
  let data_object = JSON.parse(some_object.data);
  return data_object[field];
}

export function get_data_field_object_as_array_js(some_object, field) {
  let data_object = JSON.parse(some_object.data);
  let field_data = data_object[field];
  let field_map = new Map(Object.entries(field_data));
  let array = [];
  field_map.forEach((value, key) => {
    value.unshift(key);
    array.push(value);
  });
  return array;
}

export function ws_init_js() {
  const socket = new WebSocket("ws://" + location.hostname + ":8000/ws");

  socket.onopen = function (e) {
    // alert("[open] Connection established");
    // alert("Sending to server");
  };

  socket.onmessage = function (event) {
    // on ping
    if (event.data === "1") {
      socket.send("0");
      return;
    }
    // alert(`[message] Data received from server: ${event.data}`);
  };

  socket.onclose = function (event) {
    if (event.wasClean) {
      //   alert(
      //     `[close] Connection closed cleanly, code=${event.code} reason=${event.reason}`
      //   );
    } else {
      // e.g. server process killed or network down
      // event.code is usually 1006 in this case
      //   alert("[close] Connection died");
    }
  };

  socket.onerror = function (error) {
    // alert(`[error]`);
  };

  return socket;
}

export function ws_onopen_js(socket, callback) {
  socket.onopen = callback;
}

export function ws_onmessage_js(socket, callback) {
  socket.onmessage = callback;
}

export function ws_onclose_js(socket, callback) {
  socket.onclose = callback;
}

export function ws_send_move_js(socket, message) {
  message = Object.assign({ type: "move" }, message);
  socket.send(JSON.stringify(message));
}

export function ws_send_game_data_request_js(socket, message) {
  socket.onopen = function (e) {
    message = Object.assign({ type: "request_game_data"}, message);
    socket.send(JSON.stringify(message));
  };
}

export function ws_request_game_with_computer_js(socket, color) {
  var message = { type: "request_game_with_computer", color: color };
  socket.send(JSON.stringify(message));
}

export function set_pathname_js(pathname) {
  const nextURL = pathname;
  const nextTitle = 'set pathname';
  const nextState = { additionalInformation: 'Updated the URL with JS' };

  // This will create a new entry in the browser's history, without reloading
  window.history.pushState(nextState, nextTitle, nextURL);
}

export function set_navigation_button_callback_js(callback) {
  window.addEventListener('popstate', function (event) {
      callback(location.pathname)
  });  
}

export function console_log_js(message) {
  console.log(message);
}

export function url_pathname_js() {
  return window.location.pathname;
}

export function get_color_select_value_js() {
  return document.getElementById("color-select").value;
}
