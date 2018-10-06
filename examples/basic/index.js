"use strict";

var React = require("react");
var ReactDOM = require("react-dom");
var Counter = require("./output/bundle.js");

ReactDOM.render(
  Counter.todoExample,
  document.getElementById("container")
);
