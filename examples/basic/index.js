"use strict";

const ReactDOM = require("react-dom");
const TodoExample = require("./output/bundle.js");

ReactDOM.render(
  TodoExample.mkTodoExample()(),
  document.getElementById("container")
);
