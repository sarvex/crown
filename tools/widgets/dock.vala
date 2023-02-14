/*
 * Copyright (c) 2012-2023 Daniele Bartolini et al.
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

//
// $ vala dock.vala --pkg gtk+-3.0 --pkg libdazzle-1.0
//

// TODO:
// [x] sometimes docking leaves behind widgets
// [x] drag_leave events always increase after split_and_insert()
// [ ] sometimes docking gets stuck in "dragging mode"

using Gtk;
using Gdk;

public const Gtk.TargetEntry[] targets =
{
	{ "INTEGER", 0, 0 },
};

public int mouse_x = 0;
public int mouse_y = 0;
public int num_buttons = 2;
public int num_outer_buttons = 1;

[Flags]
public enum HandleSide
{
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	CENTER
}

public HandleSide draw_outer_split_handles(Cairo.Context cr, Gtk.Allocation alloc, Gdk.Rectangle mouse_rect)
{
	// Everything in pixel units.
	int center_x = alloc.width / 2;
	int center_y = alloc.height / 2;
	int handle_half_width  = 16;
	int handle_half_height = 16;

	Gdk.Rectangle top =
	{
		center_x - handle_half_width,
		-handle_half_height,
		2*handle_half_width,
		2*handle_half_height
	};

	Gdk.Rectangle bottom =
	{
		center_x - handle_half_width,
		alloc.height - handle_half_height,
		2*handle_half_width,
		2*handle_half_height
	};

	Gdk.Rectangle left =
	{
		-handle_half_width,
		center_y - handle_half_height,
		2*handle_half_width,
		2*handle_half_height
	};

	Gdk.Rectangle right =
	{
		alloc.width - handle_half_width,
		center_y - handle_half_height,
		2*handle_half_width,
		2*handle_half_height
	};

	HandleSide hit_mask = 0;

	if (top.intersect(mouse_rect, null))
		hit_mask |= HandleSide.TOP;
	else if (bottom.intersect(mouse_rect, null))
		hit_mask |= HandleSide.BOTTOM;
	else if (left.intersect(mouse_rect, null))
		hit_mask |= HandleSide.LEFT;
	else if (right.intersect(mouse_rect, null))
		hit_mask |= HandleSide.RIGHT;

	Gdk.RGBA black  = { 0.0, 0.0, 0.0, 0.5 };
	Gdk.RGBA yellow = { 1.0, 1.0, 0.0, 0.5 };

	Gdk.cairo_set_source_rgba(cr, HandleSide.TOP in hit_mask ? yellow : black);
	cr.rectangle(
		top.x,
		top.y,
		top.width,
		top.height
		);
	cr.fill();
	Gdk.cairo_set_source_rgba(cr, HandleSide.BOTTOM in hit_mask ? yellow : black);
	cr.rectangle(
		bottom.x,
		bottom.y,
		bottom.width,
		bottom.height
		);
	cr.fill();
	Gdk.cairo_set_source_rgba(cr, HandleSide.LEFT in hit_mask ? yellow : black);
	cr.rectangle(
		left.x,
		left.y,
		left.width,
		left.height
		);
	cr.fill();
	Gdk.cairo_set_source_rgba(cr, HandleSide.RIGHT in hit_mask ? yellow : black);
	cr.rectangle(
		right.x,
		right.y,
		right.width,
		right.height
		);
	cr.fill();

	return hit_mask;
}

// Draws handles and returns a bitmask with the handle that has been hit.
public HandleSide draw_inner_split_handles(Cairo.Context cr, Gtk.Allocation alloc, Gdk.Rectangle mouse_rect)
{
	// Everything in pixel units.
	int center_x = alloc.width / 2;
	int center_y = alloc.height / 2;
	int handle_half_width  = 16;
	int handle_half_height = 16;
	int padding_x = 25;
	int padding_y = 25;

	Gdk.Rectangle top =
	{
		center_x - handle_half_width,
		center_y - 2*handle_half_height - padding_y,
		2*handle_half_width,
		2*handle_half_height
	};

	Gdk.Rectangle bottom =
	{
		center_x - handle_half_width,
		center_y + padding_y,
		2*handle_half_width,
		2*handle_half_height
	};

	Gdk.Rectangle left =
	{
		center_x - 2*handle_half_width - padding_x,
		center_y - handle_half_height,
		2*handle_half_width,
		2*handle_half_height
	};

	Gdk.Rectangle right =
	{
		center_x + padding_x,
		center_y - handle_half_height,
		2*handle_half_width,
		2*handle_half_height
	};

	Gdk.Rectangle center =
	{
		center_x - handle_half_width,
		center_y - handle_half_height,
		2*handle_half_width,
		2*handle_half_height
	};

	HandleSide hit_mask = 0;

	if (top.intersect(mouse_rect, null))
		hit_mask |= HandleSide.TOP;
	else if (bottom.intersect(mouse_rect, null))
		hit_mask |= HandleSide.BOTTOM;
	else if (left.intersect(mouse_rect, null))
		hit_mask |= HandleSide.LEFT;
	else if (right.intersect(mouse_rect, null))
		hit_mask |= HandleSide.RIGHT;
	else if (center.intersect(mouse_rect, null))
		hit_mask |= HandleSide.CENTER;

	Gdk.RGBA black  = { 0.0, 0.0, 0.0, 0.5 };
	Gdk.RGBA yellow = { 1.0, 1.0, 0.0, 0.5 };

	Gdk.cairo_set_source_rgba(cr, HandleSide.TOP in hit_mask ? yellow : black);
	cr.rectangle(
		top.x,
		top.y,
		top.width,
		top.height
		);
	cr.fill();
	Gdk.cairo_set_source_rgba(cr, HandleSide.BOTTOM in hit_mask ? yellow : black);
	cr.rectangle(
		bottom.x,
		bottom.y,
		bottom.width,
		bottom.height
		);
	cr.fill();
	Gdk.cairo_set_source_rgba(cr, HandleSide.LEFT in hit_mask ? yellow : black);
	cr.rectangle(
		left.x,
		left.y,
		left.width,
		left.height
		);
	cr.fill();
	Gdk.cairo_set_source_rgba(cr, HandleSide.RIGHT in hit_mask ? yellow : black);
	cr.rectangle(
		right.x,
		right.y,
		right.width,
		right.height
		);
	cr.fill();
	Gdk.cairo_set_source_rgba(cr, HandleSide.CENTER in hit_mask ? yellow : black);
	cr.rectangle(
		center.x,
		center.y,
		center.width,
		center.height
		);
	cr.fill();

	return hit_mask;
}

public class NotebookTab : Gtk.EventBox
{
	public Notebook _notebook;
	public Gtk.Widget _widget;
	public Gtk.Widget _label_widget;

	public NotebookTab(Notebook notebook, Gtk.Widget widget, Gtk.Widget label_widget)
	{
		_notebook = notebook;
		_widget = widget;
		_label_widget = label_widget;

		Gtk.drag_source_set(this
			, Gdk.ModifierType.BUTTON1_MASK
			, targets
			, Gdk.DragAction.MOVE
			);

		this.drag_begin.connect(on_drag_begin);
		this.drag_end.connect(on_drag_end);

		this.add(label_widget);
		this.show_all();
	}

	public Gtk.Widget steal_label_widget()
	{
		this.remove(_label_widget);
		return _label_widget;
	}

	public void on_drag_begin(DragContext context)
	{
		stdout.printf("drag begin notebook %p eb %p\n", _notebook, _notebook._drop_area);

		_notebook._multipaned._dock.notebook_tab_drag_begin();
	}

	public void on_drag_end(DragContext context)
	{
		stdout.printf("drag end notebook %p eb %p\n", _notebook, _notebook._drop_area);

		_notebook._multipaned._dock.notebook_tab_drag_end();
	}
}

public class DropArea : Gtk.EventBox
{
	public Notebook _notebook;
	public bool _should_draw;
	public HandleSide _hit_mask;

	public DropArea(Notebook nb)
	{
		_notebook = nb;
		_should_draw = false;
		_hit_mask = 0;

		Gtk.drag_dest_set(this
			, Gtk.DestDefaults.MOTION | Gtk.DestDefaults.HIGHLIGHT
			, targets
			, Gdk.DragAction.MOVE
			);

		this.draw.connect(on_draw);
		this.drag_motion.connect(on_drag_motion);
		this.drag_leave.connect(on_drag_leave);
		this.drag_drop.connect(on_drag_drop);
	}

	public bool on_draw(Gtk.Widget widget, Cairo.Context cr)
	{
		if (!_should_draw)
			return Gdk.EVENT_PROPAGATE;

		Gdk.Rectangle mouse_rect = { mouse_x, mouse_y, 2, 2 };
		Gtk.Allocation alloc;
		widget.get_allocation(out alloc);
		_hit_mask = draw_inner_split_handles(cr, alloc, mouse_rect);
		return Gdk.EVENT_PROPAGATE;
	}

	public bool on_drag_motion(DragContext context, int x, int y, uint time_)
	{
		// stdout.printf("dragging\n");
		mouse_x = x;
		mouse_y = y;
		_should_draw = true;
		Dock dock = _notebook._multipaned._dock;
		dock._dragging = true;
		dock.queue_draw();
		this.queue_draw();
		return Gdk.EVENT_PROPAGATE;
	}

	public void on_drag_leave(DragContext context, uint time_)
	{
		stdout.printf("drag leave from drop_area %p\n", this);
		_should_draw = false;
		Dock dock = _notebook._multipaned._dock;
		dock._dragging = false;
		dock.queue_draw();
		this.queue_draw();
	}

	public bool on_drag_drop(DragContext context, int x, int y, uint time_)
	{
		Gtk.Widget source_widget = Gtk.drag_get_source_widget(context);
		if (source_widget is NotebookTab) {
			stdout.printf("Dropped NotebookTab %p\n", source_widget);
		}

		Multipaned mp = _notebook._multipaned;

		// Check whether the widget has been dropped on a hot-spot.
		if (HandleSide.TOP in _hit_mask) {
			mp.split_and_insert(_notebook, (NotebookTab)source_widget, Gtk.Orientation.VERTICAL, 0);
			drag_finish(context, true, true, time_);
			return Gdk.EVENT_STOP;
		} else if (HandleSide.BOTTOM in _hit_mask) {
			mp.split_and_insert(_notebook, (NotebookTab)source_widget, Gtk.Orientation.VERTICAL, 1);
			drag_finish(context, true, true, time_);
			return Gdk.EVENT_STOP;
		} else if (HandleSide.LEFT in _hit_mask) {
			mp.split_and_insert(_notebook, (NotebookTab)source_widget, Gtk.Orientation.HORIZONTAL, 0);
			drag_finish(context, true, true, time_);
			return Gdk.EVENT_STOP;
		} else if (HandleSide.RIGHT in _hit_mask) {
			mp.split_and_insert(_notebook, (NotebookTab)source_widget, Gtk.Orientation.HORIZONTAL, 1);
			drag_finish(context, true, true, time_);
			return Gdk.EVENT_STOP;
		} else if (HandleSide.CENTER in _hit_mask) {
			mp.add_center(_notebook, (NotebookTab)source_widget);
			drag_finish(context, true, true, time_);
			return Gdk.EVENT_STOP;
		} else { // No hits inside inner handles.
			Dock dock = mp._dock;
			dock.widget_dropped((NotebookTab)source_widget);
			drag_finish(context, true, true, time_);
			return Gdk.EVENT_STOP;
		}
	}
}

public class Notebook : Gtk.Overlay
{
	public Multipaned? _multipaned;
	public Gtk.Notebook _notebook;
	public DropArea _drop_area;

	public Notebook()
	{
		_multipaned = null;

		_notebook = new Gtk.Notebook();
		_notebook.expand = true;
		_notebook.show_tabs = true;
		_notebook.page_removed.connect(on_page_removed);
		_notebook.set_scrollable(true); // The tab label area will have arrows for scrolling.

		_drop_area = new DropArea(this);
		_drop_area.set_visible_window(false);

		this.add(_notebook);
		this.add_overlay(_drop_area);
	}

	public void append_page(Gtk.Widget widget, Gtk.Widget label_widget)
	{
		widget.show_all(); // To make Gtk.Notebook happy.

		NotebookTab tab_widget = new NotebookTab(this, widget, label_widget);

		_notebook.append_page(widget, tab_widget);
		_notebook.set_tab_reorderable(widget, true);
		_notebook.set_tab_detachable(widget, false); // Custom D&D.
		_notebook.set_current_page(-1); // Last page added.
	}

	public void on_page_removed(Widget child, uint page_num)
	{
		stdout.printf("on_page_removed child %p n_pages %d\n", child, _notebook.get_n_pages());
		if (_notebook.get_n_pages() == 0) {
			stdout.printf("destroyed notebookt %p multipaned %p\n", _notebook, _multipaned);
			_notebook.destroy();
		}
	}

	public int get_n_pages()
	{
		return _notebook.get_n_pages();
	}

	public void detach_child(Gtk.Widget child)
	{
		_notebook.remove(child);
	}
}

public class Dock : Gtk.Bin
{
	public Multipaned _multipaned;
	public HandleSide _hit_mask;
	public bool _dragging;

	public Dock()
	{
		_multipaned = new Multipaned(this, Gtk.Orientation.HORIZONTAL);

		_hit_mask = 0;

		_dragging = false;

		base.add(_multipaned);

		this.events |= EventMask.POINTER_MOTION_MASK;
		this.motion_notify_event.connect((ev) => {
			// print("%d %d\n", (int)ev.x, (int)ev.y);
			return Gdk.EVENT_PROPAGATE;
		});

		this.draw.connect_after((widget, cr) => {
			// Connect after to draw handles over child widgets.
			if (!_dragging)
				return Gdk.EVENT_PROPAGATE;

			int xx;
			int yy;
			this.get_window().get_device_position(Gdk.Display.get_default().get_device_manager().get_client_pointer()
				, out xx
				, out yy
				, null
				);

			Gdk.Rectangle mouse_rect = { xx, yy, 2, 2 };
			Gtk.Allocation alloc;
			widget.get_allocation(out alloc);
			_hit_mask = draw_outer_split_handles(cr, alloc, mouse_rect);
			return Gdk.EVENT_PROPAGATE;
		});

		this.show.connect(on_show);
	}

	public void widget_dropped(NotebookTab tab)
	{
		print("hit_mask %d\n", _hit_mask);
		if (_hit_mask == 0) // No hits.
			return;

		if (HandleSide.TOP in _hit_mask)
			split_and_push_front(tab, Gtk.Orientation.VERTICAL);
		else if (HandleSide.BOTTOM in _hit_mask)
			split_and_push_back(tab, Gtk.Orientation.VERTICAL);
		else if (HandleSide.LEFT in _hit_mask)
			split_and_push_front(tab, Gtk.Orientation.HORIZONTAL);
		else if (HandleSide.RIGHT in _hit_mask)
			split_and_push_back(tab, Gtk.Orientation.HORIZONTAL);
		else
			assert(false);
	}

	public void split_and_push_front(NotebookTab tab, Gtk.Orientation orientation)
	{
		stdout.printf("split and push front\n");

		if (_multipaned.orientation == orientation) {
			uint num_children = _multipaned.get_n_children();
			Gtk.Widget[] old_widgets = new Gtk.Widget[num_children];

			// Copy all children refs to re-add them later on.
			for (int ii = 0; ii < num_children; ++ii) {
				Gtk.Widget child_ii = _multipaned.get_nth_child(ii);
				old_widgets[ii] = child_ii; // Save ref
			}

			// Remove all children.
			for (int ii = 0; ii < num_children; ++ii) {
				_multipaned.remove(old_widgets[ii]);
			}

			Gtk.Widget widget = tab._widget;
			tab._notebook.remove(widget);
			_multipaned.add_with_notebook(widget, tab.steal_label_widget());

			// Re-add previously removed children.
			for (int ii = 0; ii < num_children; ++ii) {
				if (old_widgets[ii] == tab._notebook && tab._notebook.get_n_pages() == 0)
					continue;

				_multipaned.add(old_widgets[ii]);
			}

			_multipaned.show_all();
		} else {
			var new_mp = new Multipaned(this, orientation);
			Notebook src_notebook = tab._notebook;
			Gtk.Widget src_notebook_widget = tab._widget;
			src_notebook.remove(src_notebook_widget);
			new_mp.add_with_notebook(src_notebook_widget, tab.steal_label_widget());
			new_mp.add(_multipaned);
			new_mp.show_all();
			_multipaned = new_mp;
		}
	}

	public void split_and_push_back(Gtk.Widget widget, Gtk.Orientation orientation)
	{
		if (_multipaned.orientation == orientation) {
			_multipaned.add_with_notebook(widget, new Gtk.Label("Helo"));
			_multipaned.show_all();
		} else {
			var new_mp = new Multipaned(this, orientation);
			new_mp.add(_multipaned);
			new_mp.add_with_notebook(widget, new Gtk.Label("Ochei"));
			new_mp.show_all();
			_multipaned = new_mp;
		}
	}

	public void set_event_box_visible(Multipaned mp, bool visible)
	{
		List<unowned Widget> children = mp.get_children();

		foreach (var child in children) {
			if (child is Multipaned) {
				set_event_box_visible((Multipaned)child, visible);
			} else {
				Notebook nb = (Notebook)child;
				stdout.printf("child %p eb %p\n", child, nb._drop_area);
				nb._drop_area.visible = visible;
			}
		}
	}

	public void notebook_tab_drag_begin()
	{
		set_event_box_visible(_multipaned, true);
	}

	public void notebook_tab_drag_end()
	{
		set_event_box_visible(_multipaned, false);
	}

	public void on_show()
	{
		stdout.printf("show dock\n");
		set_event_box_visible(_multipaned, false);
	}
}

public class Multipaned : Dazzle.MultiPaned
{
	public Dock _dock;

	public Multipaned(Dock dock, Gtk.Orientation orientation)
	{
		this._dock = dock;

		this.orientation = orientation;
	}

	// Adds @a widget to the end of the multipane, creating a new notebook to
	// accommodate it.
	public Notebook add_with_notebook(Gtk.Widget widget, Gtk.Widget label_widget)
	{
		Notebook nb = new Notebook();
		nb.append_page(widget, label_widget);

		add(nb);
		return nb;
	}

	public override void add(Gtk.Widget widget)
	{
		if (widget is Notebook) {
			Notebook nb = (Notebook)widget;
			nb._multipaned = this;
		} else if (widget is Multipaned) {
			// Do nothing.
		} else {
			assert(false);
		}

		base.add(widget);
	}

	// Adds @a widget on the top-side of @a target. If @a reverse is non-zero,
	// the order is resversed.
	public void split_and_insert(Notebook dst_notebook, NotebookTab tab, Gtk.Orientation orientation, int reverse = 0)
	{
		stdout.printf("split_and_insert: dst_notebook %p tab %p src_notebook %p\n", dst_notebook, tab, tab._notebook);

		Notebook src_notebook = tab._notebook;
		if (src_notebook == dst_notebook && src_notebook.get_n_pages() < 2) {
			stdout.printf("split_and_insert: can't split an only child\n");
			return;
		}

		Multipaned dst_mp = dst_notebook._multipaned;

		// HACK: remove all children and later re-add them in correct order.
		uint num_children = dst_mp.get_n_children();
		Gtk.Widget[] old_widgets = new Gtk.Widget[num_children];

		for (int ii = 0; ii < num_children; ++ii) {
			old_widgets[ii] = dst_mp.get_nth_child(ii); // Save ref
		}

		for (int ii = 0; ii < num_children; ++ii) {
			dst_mp.remove(old_widgets[ii]);
		}

		//
		Multipaned src_mp = src_notebook._multipaned;
		if (src_mp != dst_mp) {
			src_mp.remove(src_notebook);
		}

		Gtk.Widget src_notebook_widget = tab._widget;

		stdout.printf("num_children %u\n", num_children);
		for (int ii = 0; ii < num_children; ++ii) {
			stdout.printf("old_widgets[%d] = %p\n", ii, old_widgets[ii]);
			if (old_widgets[ii] == dst_notebook) {
				if (src_notebook.get_n_pages() == 1 && src_notebook == dst_notebook) {
					stdout.printf("helo?\n");
					dst_mp.add(src_notebook);
					continue;
				}

				src_notebook.detach_child(src_notebook_widget);

				// Add widget to a new notebook.
				Notebook nb = new Notebook();
				nb.append_page(src_notebook_widget, tab.steal_label_widget());

				Notebook left  = nb;
				Notebook right = dst_notebook;
				if (reverse != 0) {
					left  = dst_notebook;
					right = nb;
				}

				Multipaned new_mp = dst_mp; // Multipaned is the same as before.

				if (dst_mp.orientation == orientation) {
					// No need to create new dst_mp if orientation matches.
					dst_mp.add(left);
					dst_mp.add(right);
				} else {
					// Create new multipaned.
					new_mp = new Multipaned(dst_mp._dock, orientation);
					new_mp.add(left);
					new_mp.add(right);

					dst_mp.add(new_mp);
				}
			} else {
				// Add in the same order as before.
				if (old_widgets[ii] == src_notebook) {
					stdout.printf("skipped src_notebook %p\n", src_notebook);
					continue;
				}

				stdout.printf("adding %p\n", old_widgets[ii]);
				dst_mp.add(old_widgets[ii]);
			}
		}

		stdout.printf("end of split_and_insert\n");

		dst_mp.show_all();
	}

	public void add_center(Notebook dst_notebook, NotebookTab tab)
	{
		Notebook src_notebook = tab._notebook;
		if (src_notebook == dst_notebook) {
			stdout.printf("add_center: into itself...\n");
			return;
		}

		// Migrate tab from src to dst notebook.
		src_notebook.detach_child(tab._widget);
		dst_notebook.append_page(tab._widget, tab.steal_label_widget());

		if (src_notebook.get_n_pages() == 0)
			src_notebook._multipaned.remove(src_notebook);
	}
}

// A regular Gtk.EventBox which keeps its original Gdk.Window alive.
public class MyEventBox : Gtk.EventBox
{
	public bool _realized;

	public MyEventBox()
	{
		_realized = false;
	}

	public override void realize()
	{
		if (_realized) {
			this.set_realized(true);
			return;
		}

		base.realize();
		_realized = true;
	}

	public override void unrealize()
	{
		// Do not destroy the internal Gdk.Window.
		return;
	}
}

// A regular Gtk.Stack which keeps its original Gdk.Window alive.
public class MyStack : Gtk.Stack
{
	public bool _realized;

	public MyStack()
	{
		_realized = false;
	}

	public override void realize()
	{
		if (_realized) {
			this.set_realized(true);
			return;
		}

		base.realize();
		_realized = true;
	}

	public override void unrealize()
	{
		// Do not destroy the internal Gdk.Window.
		return;
	}
}

#if !CROWN_PLATFORM_LINUX && !CROWN_PLATFORM_WINDOWS
void main(string[] args)
{
	Gtk.init (ref args);

	var window = new Gtk.Window ();
	window.set_default_size (1000, 400);
	window.window_position = Gtk.WindowPosition.CENTER;

	var dock = new Dock();

	Notebook nb = null;
	Gtk.Widget ww = null;

	ww = new Gtk.Button.with_label("Foo");
	nb = dock._multipaned.add_with_notebook(ww, new Gtk.Label("Foo"));
	nb.append_page(new Gtk.Button.with_label("Bar"), new Gtk.Label("Bar"));

	ww = new Gtk.Entry();
	Gtk.drag_dest_set(ww
		, Gtk.DestDefaults.MOTION | Gtk.DestDefaults.HIGHLIGHT
		, targets
		, Gdk.DragAction.MOVE
		);
	nb = dock._multipaned.add_with_notebook(ww, new Gtk.Label("Baz"));

	ww = new MyEventBox();
	var st = new MyStack();
	st.add(ww);
	nb = dock._multipaned.add_with_notebook(st, new Gtk.Label("EvBox"));

	window.add(dock);
	window.show_all();

	Gtk.main ();
}

#endif /* if !CROWN_PLATFORM_LINUX */
