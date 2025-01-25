extends RefCounted
class_name UIResourceManager

## UI资源管理器
## 负责管理UI资源的加载、缓存和对象池

# 信号
signal resource_loaded(path: String, resource: Resource)
signal resource_unloaded(path: String)

# 内部变量
var _resource_cache: Dictionary = {}
var _instance_pools: Dictionary = {}

## 资源加载模式
enum LoadMode { IMMEDIATE, LAZY }

## 加载资源
## [param path] 资源路径
## [param mode] 加载模式
## [return] 加载的资源
func load_resource(path: String, mode: LoadMode = LoadMode.IMMEDIATE) -> Resource:
	if _resource_cache.has(path):
		return _resource_cache[path]
		
	var resource: Resource
	if mode == LoadMode.IMMEDIATE:
		resource = load(path)
		if resource:
			_resource_cache[path] = resource
			resource_loaded.emit(path, resource)
	else:
		ResourceLoader.load_threaded_request(path)
		_resource_cache[path] = null
		
	return resource

## 获取缓存的资源
## [param path] 资源路径
## [return] 缓存的资源
func get_cached_resource(path: String) -> Resource:
	return _resource_cache.get(path)

## 清理资源缓存
## [param path] 资源路径，为空则清理所有缓存
func clear_resource_cache(path: String = "") -> void:
	if path.is_empty():
		_resource_cache.clear()
		resource_unloaded.emit("")
	elif _resource_cache.has(path):
		_resource_cache.erase(path)
		resource_unloaded.emit(path)

## 从对象池获取实例
## [param id] 实例ID
## [return] 池中的实例
func get_instance(id: StringName) -> Node:
	if not _instance_pools.has(id):
		return null
		
	var pool = _instance_pools[id]
	if pool.is_empty():
		return null
		
	return pool.pop_back()

## 回收实例到对象池
## [param id] 实例ID
## [param instance] 要回收的实例
func recycle_instance(id: StringName, instance: Node) -> void:
	if not _instance_pools.has(id):
		_instance_pools[id] = []
		
	if instance.get_parent():
		instance.get_parent().remove_child(instance)
		
	_instance_pools[id].append(instance)

## 处理异步加载
## [param delta] 处理间隔
func process(delta: float) -> void:
	var loading_paths = []
	for path in _resource_cache:
		if _resource_cache[path] == null:
			loading_paths.append(path)
	
	for path in loading_paths:
		var status = ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var resource = ResourceLoader.load_threaded_get(path)
			_resource_cache[path] = resource
			resource_loaded.emit(path, resource)
