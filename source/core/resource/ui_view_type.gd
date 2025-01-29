@tool
extends Resource
class_name UIViewType

## UI视图类型基类
## 提供基础的UI资源类型功能，用于定义视图的加载和缓存策略

## 预加载模式
enum PRELOAD_MODE { 
	NONE, 				## 不预加载
	PRELOAD, 			## 预加载
	LAZY_LOAD 			## 延迟加载
	}
## 缓存模式
enum CACHE_MODE { 
	NONE, 				## 不缓存
	CACHE_IN_MEMORY,    ## 在内存中缓存
	}

# 属性
## 视图ID，用于唯一标识视图类型
@export var ID: StringName
## 场景路径，指向视图的场景文件
@export_file("*.tscn") var scene_path: String
## 预加载模式，控制视图资源的加载时机
@export var preload_mode: PRELOAD_MODE = PRELOAD_MODE.NONE
## 缓存模式，控制视图实例的缓存策略
@export var cache_mode: CACHE_MODE = CACHE_MODE.CACHE_IN_MEMORY
## 池容量（仅当 cache_mode 为 CACHE_IN_MEMORY 时有效）
@export var pool_capacity: int = 10

## 验证配置
func validate() -> bool:
	if ID.is_empty():
		push_error("View ID cannot be empty")
		return false
	
	if scene_path.is_empty():
		push_error("Scene path cannot be empty")
		return false
	
	if not FileAccess.file_exists(scene_path):
		push_error("Scene file not found: %s" % scene_path)
		return false
	
	return true

## 复制配置
func duplicate_type() -> UIViewType:
	var copy = super.duplicate()
	copy.ID = ID
	copy.scene_path = scene_path
	copy.preload_mode = preload_mode
	copy.cache_mode = cache_mode
	return copy
