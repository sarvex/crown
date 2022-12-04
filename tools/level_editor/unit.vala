/*
 * Copyright (c) 2012-2022 Daniele Bartolini et al.
 * License: https://github.com/crownengine/crown/blob/master/LICENSE
 */

using Gee;

namespace Crown
{
public class Unit
{
	public Database _db;
	public Guid _id;

	public Unit(Database db, Guid id)
	{
		_db = db;
		_id = id;
	}

	/// Loads the unit @a name.
	public static void load_unit(Database db, string name)
	{
		string resource_path = name + ".unit";

		Guid prefab_id = GUID_ZERO;
		if (db.add_from_resource_path(out prefab_id, resource_path) != 0)
			return; // Caller can query the database to check for error.
		assert(prefab_id != GUID_ZERO);
	}

	public Value? get_component_property(Guid component_id, string key)
	{
		Value? val;

		// Search in components
		val = _db.get_property(_id, "components");
		if (val != null) {
			if (((HashSet<Guid?>)val).contains(component_id))
				return _db.get_property(component_id, key);
		}

		// Search in modified_components
		val = _db.get_property(_id, "modified_components.#" + component_id.to_string() + "." + key);
		if (val != null)
			return val;

		// Search in prefab
		val = _db.get_property(_id, "prefab");
		if (val != null) {
			// Convert prefab path to object ID.
			string prefab = (string)val;
			Unit.load_unit(_db, prefab);
			Guid prefab_id = _db.get_property_guid(GUID_ZERO, prefab + ".unit");

			Unit unit = new Unit(_db, prefab_id);
			return unit.get_component_property(component_id, key);
		}

		return null;
	}

	public bool get_component_property_bool(Guid component_id, string key)
	{
		return (bool)get_component_property(component_id, key);
	}

	public double get_component_property_double(Guid component_id, string key)
	{
		return (double)get_component_property(component_id, key);
	}

	public string get_component_property_string(Guid component_id, string key)
	{
		return (string)get_component_property(component_id, key);
	}

	public Guid get_component_property_guid(Guid component_id, string key)
	{
		return (Guid)get_component_property(component_id, key);
	}

	public Vector3 get_component_property_vector3(Guid component_id, string key)
	{
		return (Vector3)get_component_property(component_id, key);
	}

	public Quaternion get_component_property_quaternion(Guid component_id, string key)
	{
		return (Quaternion)get_component_property(component_id, key);
	}

	public void set_component_property_bool(Guid component_id, string key, bool val)
	{
		// Search in components
		Value? components = _db.get_property(_id, "components");
		if (components != null && ((HashSet<Guid?>)components).contains(component_id)) {
			_db.set_property_bool(component_id, key, val);
			return;
		}

		_db.set_property_bool(_id, "modified_components.#" + component_id.to_string() + "." + key, val);
	}

	public void set_component_property_double(Guid component_id, string key, double val)
	{
		// Search in components
		Value? components = _db.get_property(_id, "components");
		if (components != null && ((HashSet<Guid?>)components).contains(component_id)) {
			_db.set_property_double(component_id, key, val);
			return;
		}

		_db.set_property_double(_id, "modified_components.#" + component_id.to_string() + "." + key, val);
	}

	public void set_component_property_string(Guid component_id, string key, string val)
	{
		// Search in components
		Value? components = _db.get_property(_id, "components");
		if (components != null && ((HashSet<Guid?>)components).contains(component_id)) {
			_db.set_property_string(component_id, key, val);
			return;
		}

		_db.set_property_string(_id, "modified_components.#" + component_id.to_string() + "." + key, val);
	}

	public void set_component_property_guid(Guid component_id, string key, Guid val)
	{
		// Search in components
		Value? components = _db.get_property(_id, "components");
		if (components != null && ((HashSet<Guid?>)components).contains(component_id)) {
			_db.set_property_guid(component_id, key, val);
			return;
		}

		_db.set_property_guid(_id, "modified_components.#" + component_id.to_string() + "." + key, val);
	}

	public void set_component_property_vector3(Guid component_id, string key, Vector3 val)
	{
		// Search in components
		Value? components = _db.get_property(_id, "components");
		if (components != null && ((HashSet<Guid?>)components).contains(component_id)) {
			_db.set_property_vector3(component_id, key, val);
			return;
		}

		_db.set_property_vector3(_id, "modified_components.#" + component_id.to_string() + "." + key, val);
	}

	public void set_component_property_quaternion(Guid component_id, string key, Quaternion val)
	{
		// Search in components
		Value? components = _db.get_property(_id, "components");
		if (components != null && ((HashSet<Guid?>)components).contains(component_id)) {
			_db.set_property_quaternion(component_id, key, val);
			return;
		}

		_db.set_property_quaternion(_id, "modified_components.#" + component_id.to_string() + "." + key, val);
	}

	/// Returns whether the @a unit_id has a component of type @a component_type.
	public static bool has_component_static(out Guid component_id, out Guid owner_id, string component_type, Database db, Guid unit_id)
	{
		Value? val;
		component_id = GUID_ZERO;
		owner_id = GUID_ZERO;
		bool prefab_has_component = false;

		// If the component type is found inside the "components" array, the unit has the component
		// and it owns it.
		val = db.get_property(unit_id, "components");
		if (val != null) {
			foreach (Guid id in (HashSet<Guid?>)val) {
				if ((string)db.object_type(id) == component_type) {
					component_id = id;
					owner_id = unit_id;
					return true;
				}
			}
		}

		// Otherwise, search if any prefab has the component.
		val = db.get_property(unit_id, "prefab");
		if (val != null) {
			// Convert prefab path to object ID.
			string prefab = (string)val;
			Unit.load_unit(db, prefab);
			Guid prefab_id = db.get_property_guid(GUID_ZERO, prefab + ".unit");

			prefab_has_component = has_component_static(out component_id
				, out owner_id
				, component_type
				, db
				, prefab_id
				);
		}

		// If the prefab does not have the component, the unit does not as well.
		if (prefab_has_component)
			return db.get_property(unit_id, "deleted_components.#" + component_id.to_string()) == null;

		component_id = GUID_ZERO;
		owner_id = GUID_ZERO;
		return false;
	}

	/// Returns whether the unit has the component_type.
	public bool has_component_with_owner(out Guid component_id, out Guid owner_id, string component_type)
	{
		return Unit.has_component_static(out component_id, out owner_id, component_type, _db, _id);
	}

	/// Returns whether the unit has the component_type.
	public bool has_component(out Guid component_id, string component_type)
	{
		Guid owner_id;
		return has_component_with_owner(out component_id, out owner_id, component_type);
	}

	public void send_component_type(ConsoleClient _editor, Guid unit_id, Guid component_id)
	{
		string component_type = _db.get_property_string(component_id, "type");
		Unit unit = new Unit(_db, unit_id);

		if (component_type == OBJECT_TYPE_TRANSFORM) {
			_editor.send_script(LevelEditorApi.move_object(unit_id
				, unit.get_component_property_vector3   (component_id, "data.position")
				, unit.get_component_property_quaternion(component_id, "data.rotation")
				, unit.get_component_property_vector3   (component_id, "data.scale")
				));
		} else if (component_type == OBJECT_TYPE_CAMERA) {
			_editor.send_script(LevelEditorApi.set_camera(unit_id
				, unit.get_component_property_string(component_id, "data.projection")
				, unit.get_component_property_double(component_id, "data.fov")
				, unit.get_component_property_double(component_id, "data.far_range")
				, unit.get_component_property_double(component_id, "data.near_range")
				));
		} else if (component_type == OBJECT_TYPE_MESH_RENDERER) {
			_editor.send_script(LevelEditorApi.set_mesh(unit_id
				, unit.get_component_property_string(component_id, "data.material")
				, unit.get_component_property_bool  (component_id, "data.visible")
				));
		} else if (component_type == OBJECT_TYPE_SPRITE_RENDERER) {
			_editor.send_script(LevelEditorApi.set_sprite(unit_id
				, unit.get_component_property_string(component_id, "data.sprite_resource")
				, unit.get_component_property_string(component_id, "data.material")
				, unit.get_component_property_double(component_id, "data.layer")
				, unit.get_component_property_double(component_id, "data.depth")
				, unit.get_component_property_bool  (component_id, "data.visible")
				));
		} else if (component_type == OBJECT_TYPE_LIGHT) {
			_editor.send_script(LevelEditorApi.set_light(unit_id
				, unit.get_component_property_string (component_id, "data.type")
				, unit.get_component_property_double (component_id, "data.range")
				, unit.get_component_property_double (component_id, "data.intensity")
				, unit.get_component_property_double (component_id, "data.spot_angle")
				, unit.get_component_property_vector3(component_id, "data.color")
				));
		} else if (component_type == OBJECT_TYPE_SCRIPT) {
			/* No sync. */
		} else if (component_type == OBJECT_TYPE_COLLIDER) {
			/* No sync. */
		} else if (component_type == OBJECT_TYPE_ACTOR) {
			/* No sync. */
		} else if (component_type == OBJECT_TYPE_ANIMATION_STATE_MACHINE) {
			/* No sync. */
		} else {
			logw("Unregistered component type `%s`".printf(component_type));
		}
	}

	public void send_all_components(ConsoleClient _editor, Guid unit_id)
	{
		foreach (var entry in Unit._component_registry.entries) {
			Guid component_id;
			if (has_component(out component_id, entry.key))
				send_component_type(_editor, unit_id, component_id);
		}

		_editor.send(DeviceApi.frame());
	}

	// Adds the @a component_type to the unit and returns its ID.
	public Guid add_component_type(string component_type)
	{
		// Create a new component.
		Guid component_id = Guid.new_guid();
		_db.create(component_id, component_type);

		// Initialize component data based on its type.
		if (component_type == OBJECT_TYPE_TRANSFORM) {
			_db.set_property_vector3   (component_id, "data.position", VECTOR3_ZERO);
			_db.set_property_quaternion(component_id, "data.rotation", QUATERNION_IDENTITY);
			_db.set_property_vector3   (component_id, "data.scale", VECTOR3_ONE);
		} else if (component_type == OBJECT_TYPE_CAMERA) {
			_db.set_property_string(component_id, "data.projection", "perspective");
			_db.set_property_double(component_id, "data.fov", 45.0 * (Math.PI/180.0));
			_db.set_property_double(component_id, "data.far_range", 0.01);
			_db.set_property_double(component_id, "data.near_range", 1000.0);
		} else if (component_type == OBJECT_TYPE_MESH_RENDERER) {
			_db.set_property_string(component_id, "data.mesh_resource", "core/components/noop");
			_db.set_property_string(component_id, "data.geometry_name", "Noop");
			_db.set_property_string(component_id, "data.material", "core/components/noop");
			_db.set_property_bool  (component_id, "data.visible", true);
		} else if (component_type == OBJECT_TYPE_SPRITE_RENDERER) {
			_db.set_property_string(component_id, "data.sprite_resource", "core/components/noop");
			_db.set_property_string(component_id, "data.material", "core/components/noop");
			_db.set_property_double(component_id, "data.layer", 0);
			_db.set_property_double(component_id, "data.depth", 0);
			_db.set_property_bool  (component_id, "data.visible", true);
		} else if (component_type == OBJECT_TYPE_LIGHT) {
			_db.set_property_string (component_id, "data.type", "directional");
			_db.set_property_double (component_id, "data.range", 1.0);
			_db.set_property_double (component_id, "data.intensity", 1.0);
			_db.set_property_double (component_id, "data.spot_angle", 45.0 * (Math.PI/180.0));
			_db.set_property_vector3(component_id, "data.color", VECTOR3_ONE);
		} else if (component_type == OBJECT_TYPE_SCRIPT) {
			_db.set_property_string(component_id, "data.script_resource", "core/components/noop");
		} else if (component_type == OBJECT_TYPE_COLLIDER) {
			_db.set_property_string    (component_id, "data.shape", "box");
			_db.set_property_string    (component_id, "data.source", "mesh"); // "inline" or "mesh"
			// if "mesh"
			_db.set_property_string    (component_id, "data.scene", "core/components/noop");
			_db.set_property_string    (component_id, "data.name", "Noop");
			// if "inline"
			_db.set_property_vector3   (component_id, "data.collider_data.position", VECTOR3_ZERO);
			_db.set_property_quaternion(component_id, "data.collider_data.rotation", QUATERNION_IDENTITY);
			_db.set_property_vector3   (component_id, "data.collider_data.half_extents", VECTOR3_ZERO); // for "box"
			_db.set_property_double    (component_id, "data.collider_data.radius", 0.0); // for "sphere" and "capsule"
			_db.set_property_double    (component_id, "data.collider_data.height", 0.0); // for "capsule"
		} else if (component_type == OBJECT_TYPE_ACTOR) {
			_db.set_property_bool  (component_id, "data.lock_translation_x", false);
			_db.set_property_bool  (component_id, "data.lock_translation_y", false);
			_db.set_property_bool  (component_id, "data.lock_translation_z", false);
			_db.set_property_bool  (component_id, "data.lock_rotation_x", false);
			_db.set_property_bool  (component_id, "data.lock_rotation_y", false);
			_db.set_property_bool  (component_id, "data.lock_rotation_z", false);
			_db.set_property_string(component_id, "data.class", "static");
			_db.set_property_double(component_id, "data.mass", 1.0);
			_db.set_property_string(component_id, "data.collision_filter", "default");
			_db.set_property_string(component_id, "data.material", "default");
		} else if (component_type == OBJECT_TYPE_ANIMATION_STATE_MACHINE) {
			_db.set_property_string(component_id, "data.state_machine_resource", "core/components/noop");
		} else {
			logw("Unregistered component type `%s`".printf(component_type));
		}

		_db.add_to_set(_id, "components", component_id);

		_db.add_restore_point((int)ActionType.UNIT_ADD_COMPONENT, new Guid[] { _id, component_id });
		return component_id;
	}

	/// Removes the @a component_type from the unit.
	public void remove_component_type(string component_type)
	{
		Guid component_id;
		Guid owner_id;
		if (has_component_with_owner(out component_id, out owner_id, component_type)) {
			if (_id == owner_id) {
				_db.remove_from_set(_id, "components", component_id);
			} else {
				_db.set_property_bool(_id, "deleted_components.#" + component_id.to_string(), false);

				// Clean all modified_components keys that matches the deleted component ID.
				string[] unit_keys = _db.get_keys(_id);
				for (int ii = 0; ii < unit_keys.length; ++ii) {
					if (unit_keys[ii].has_prefix("modified_components.#" + component_id.to_string()))
						_db.set_property_null(_id, unit_keys[ii]);
				}
			}

			_db.add_restore_point((int)ActionType.UNIT_REMOVE_COMPONENT, new Guid[] { _id, component_id });
		} else {
			logw("The unit has no such component type `%s`".printf(component_type));
		}
	}

	public static Hashtable _component_registry;

	public static void register_component_type(string type, string depends_on)
	{
		if (_component_registry == null)
			_component_registry = new Hashtable();
		_component_registry[type] = depends_on;
	}

	/// Returns whether the unit has a prefab.
	public bool has_prefab()
	{
		return _db.has_property(_id, "prefab");
	}

	/// Returns whether the unit is a light unit.
	public bool is_light()
	{
		return has_prefab()
			&& _db.get_property_string(_id, "prefab") == "core/units/light";
	}

	/// Returns whether the unit is a camera unit.
	public bool is_camera()
	{
		return has_prefab()
			&& _db.get_property_string(_id, "prefab") == "core/units/camera";
	}
}

} /* namespace Crown */
