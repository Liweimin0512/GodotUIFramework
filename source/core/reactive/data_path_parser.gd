extends RefCounted
class_name DataPathParser

## 数据路径解析器
## 用于解析和计算数据路径表达式，支持逻辑运算和路径匹配

# 运算符
const OP_AND = "&"  # 与运算
const OP_OR = "|"   # 或运算
const OP_NOT = "!"  # 非运算

## 解析并计算路径表达式
## [param expr] 路径表达式
## [param changed_paths] 变更的路径列表
## [return] 表达式计算结果
func evaluate(expr: String, changed_paths: Array) -> bool:
    # 移除空格
    expr = expr.strip_edges()
    
    # 处理NOT运算
    if expr.begins_with(OP_NOT):
        return not evaluate(expr.substr(1), changed_paths)
    
    # 处理AND运算
    if OP_AND in expr:
        var parts = expr.split(OP_AND)
        for part in parts:
            if not evaluate(part.strip_edges(), changed_paths):
                return false
        return true
    
    # 处理OR运算
    if OP_OR in expr:
        var parts = expr.split(OP_OR)
        for part in parts:
            if evaluate(part.strip_edges(), changed_paths):
                return true
        return false
    
    # 基本路径匹配
    return _match_path(expr, changed_paths)

## 检查基本路径是否匹配
## [param path] 路径表达式
## [param changed_paths] 变更的路径列表
## [return] 是否匹配
func _match_path(path: String, changed_paths: Array) -> bool:
    for changed_path in changed_paths:
        # 完全匹配
        if path == changed_path:
            return true
        
        # 前缀匹配（父路径）
        if changed_path.begins_with(path + "."):
            return true
        
        # 后缀匹配（子路径）
        if path.begins_with(changed_path + "."):
            return true
    
    return false

## 解析数据路径
## [param path] 数据路径
## [return] 路径组件列表
static func parse_path(path: String) -> Array[String]:
    var components: Array[String] = []
    var current = ""
    
    for c in path:
        if c == ".":
            if not current.is_empty():
                components.append(current)
                current = ""
        else:
            current += c
    
    if not current.is_empty():
        components.append(current)
    
    return components

## 获取路径的父路径
## [param path] 数据路径
## [return] 父路径
static func get_parent_path(path: String) -> String:
    var components = parse_path(path)
    if components.size() <= 1:
        return ""
    components.pop_back()
    return ".".join(components)

## 获取路径的最后一个组件
## [param path] 数据路径
## [return] 最后一个组件
static func get_last_component(path: String) -> String:
    var components = parse_path(path)
    if components.is_empty():
        return ""
    return components[-1]

## 组合路径
## [param base] 基础路径
## [param relative] 相对路径
## [return] 组合后的路径
static func combine_path(base: String, relative: String) -> String:
    if base.is_empty():
        return relative
    if relative.is_empty():
        return base
    return base + "." + relative
