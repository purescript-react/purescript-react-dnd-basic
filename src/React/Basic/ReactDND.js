import DND from "react-dnd";

export const dndProvider_ = DND.DndProvider;

export const useDrag_ = (options) => {
  const [{ isDragging }, connectDrag] = DND.useDrag({
    item: options.item,
    collect: (monitor) => {
      const isDragging = monitor.isDragging();
      return { isDragging };
    },
  });
  return { isDragging, connectDrag };
};

export const useDrop_ = (options) => {
  const [{ id, isOver }, connectDrop] = DND.useDrop({
    accept: options.accept,
    drop: (item) => {
      if (item != null && item.id != null) {
        options.onDrop(item.id)();
      }
    },
    collect: (monitor) => {
      const item = monitor.getItem();
      const id = item && item.id;
      const isOver = monitor.isOver();
      return { id, isOver };
    },
  });
  return { id, isOver, connectDrop };
};

export const mergeTargets = (ref1) => (ref2) => {
  // shhhhhhh, don't look 🙈
  // sometimes refs are React ref objects..
  // sometimes they're functions..
  // this allows ref1 and ref2 to each follow
  // either pattern, and the returned callback
  // to be used as a ref or function as well
  const cb = (next) => {
    if (ref1) ref1.current = next;
    if (ref2) ref2.current = next;
    if (typeof ref1 === "function") ref1(next);
    if (typeof ref2 === "function") ref2(next);
  };
  Object.defineProperty(cb, "current", {
    get() {
      return ref1.current;
    },
    set(next) {
      cb(next);
    },
  });
  return cb;
};
