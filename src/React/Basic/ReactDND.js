"use strict";

var React = require("react");
var DND = require("react-dnd");

var SingleChildComponent = function(props) {
  return this;
};
SingleChildComponent.prototype = Object.create(React.Component.prototype);
SingleChildComponent.prototype.render = function() {
  return this.props.child;
};

var RenderPropComponent = function(props) {
  return this;
};
RenderPropComponent.prototype = Object.create(React.Component.prototype);
RenderPropComponent.prototype.render = function() {
  return this.props.render(this.props);
};

exports.createDragDropContext_ = function(backend) {
  return DND.DragDropContext(backend)(SingleChildComponent);
};

function commonMonitorCollect(toMaybe, monitor) {
  return {
    itemType: toMaybe(monitor.getItemType()),
    item: toMaybe(monitor.getItem()),
    initialClientOffset: toMaybe(monitor.getInitialClientOffset()),
    initialSourceClientOffset: toMaybe(monitor.getInitialSourceClientOffset()),
    clientOffset: toMaybe(monitor.getClientOffset()),
    differenceFromInitialOffset: toMaybe(
      monitor.getDifferenceFromInitialOffset()
    ),
    sourceClientOffset: toMaybe(monitor.getSourceClientOffset())
  };
}

exports.unsafeCreateDragSource = function(toMaybe, type) {
  var dragSourceMonitorCollect = function(flags, monitor) {
    return {
      canDrag: flags.canDrag ? monitor.canDrag() : toMaybe(null),
      isDragging: flags.isDragging ? monitor.isDragging() : toMaybe(null),
      dropResult: toMaybe(monitor.getDropResult()),
      didDrop: monitor.didDrop()
    };
  };
  var spec = {
    beginDrag: function(props, monitor) {
      return props.beginDrag(
        Object.assign(
          commonMonitorCollect(toMaybe, monitor),
          dragSourceMonitorCollect({ canDrag: true, isDragging: true }, monitor)
        )
      );
    },
    endDrag: function(props, monitor) {
      return props.endDrag(
        Object.assign(
          commonMonitorCollect(toMaybe, monitor),
          dragSourceMonitorCollect({ canDrag: true, isDragging: true }, monitor)
        )
      );
    },
    canDrag: function(props, monitor) {
      return props.canDrag(
        Object.assign(
          commonMonitorCollect(toMaybe, monitor),
          dragSourceMonitorCollect(
            { canDrag: false, isDragging: true },
            monitor
          )
        )
      );
    },
    isDragging: function(props, monitor) {
      return props.isDragging(
        Object.assign(
          commonMonitorCollect(toMaybe, monitor),
          dragSourceMonitorCollect(
            { canDrag: true, isDragging: false },
            monitor
          )
        )
      );
    }
  };
  var collect = function(connect, monitor) {
    return Object.assign(
      {
        connectDragSource: connect.dragSource(),
        connectDragPreview: connect.dragPreview()
      },
      commonMonitorCollect(toMaybe, monitor),
      dragSourceMonitorCollect({ canDrag: true, isDragging: true }, monitor)
    );
  };
  return DND.DragSource(type, spec, collect)(RenderPropComponent);
};

exports.unsafeCreateDropTarget = function(toMaybe, type) {
  var dropTargetMonitorCollect = function(flags, monitor) {
    return {
      canDrop: flags.canDrop ? monitor.canDrop() : toMaybe(null),
      isOver: monitor.isOver(),
      isOverShallow: monitor.isOver({ shallow: true }),
      dropResult: toMaybe(monitor.getDropResult()),
      didDrop: monitor.didDrop()
    };
  };
  var spec = {
    drop: function(props, monitor) {
      return (
        props.drop(
          Object.assign(
            commonMonitorCollect(toMaybe, monitor),
            dropTargetMonitorCollect({ canDrop: true }, monitor)
          )
        ) || undefined // `null` is not allowed, but `toNullable` returns it
      );
    },
    hover: function(props, monitor) {
      return props.hover(
        Object.assign(
          commonMonitorCollect(toMaybe, monitor),
          dropTargetMonitorCollect({ canDrop: true }, monitor)
        )
      );
    },
    canDrop: function(props, monitor) {
      return props.canDrop(
        Object.assign(
          commonMonitorCollect(toMaybe, monitor),
          dropTargetMonitorCollect({ canDrop: false }, monitor)
        )
      );
    }
  };
  var collect = function(connect, monitor) {
    return Object.assign(
      {
        connectDropTarget: connect.dropTarget()
      },
      commonMonitorCollect(toMaybe, monitor),
      dropTargetMonitorCollect({ canDrop: true }, monitor)
    );
  };
  return DND.DropTarget(type, spec, collect)(RenderPropComponent);
};

exports.unsafeCreateDragLayer = function(toMaybe) {
  var dragLayerMonitorCollect = function(monitor) {
    return {
      isDragging: monitor.isDragging()
    };
  };
  var collect = function(connect, monitor) {
    return Object.assign(
      {
        connectDragLayer: connect.dragLayer()
      },
      commonMonitorCollect(toMaybe, monitor),
      dragLayerMonitorCollect(monitor)
    );
  };
  return DND.DragLayer(collect)(RenderPropComponent);
};
