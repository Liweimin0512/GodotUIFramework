# source/module/localization/components/ui_localized_audio_component.gd
extends UILocalizationComponent
class_name UILocalizedAudioComponent

## 目标音频属性
@export var audio_property: String = "stream"

func _update_localization() -> void:
    var audio = _localization_manager.get_localized_resource(key) as AudioStream
    if audio and _owner.has_method("set_" + audio_property):
        _owner.set(audio_property, audio)