class_name AudioEventsManager
extends Node

@export var audio_player : AudioStreamPlayer
@export var segments: Array[Segment] = []
@export var autoplay: bool = false

var _current_segment: Segment

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not audio_player:
		var p: Node = get_parent()
		if p is AudioStreamPlayer:
			audio_player = p as AudioStreamPlayer
	if not audio_player:
		push_error("Audio player not found!")
		return

	if segments.is_empty():
		push_error("No segments have been selected!")
		return

	_validate_segments()

	if autoplay:
		play()
		switch_segments(0)

## Plays the audio stream (and from the start of a segment if one is selected)
func play(from_position: float = 0.0) -> void:
	audio_player.play(from_position)

	if _current_segment:
		audio_player.seek(_current_segment.start)

## Stops the audio
func stop() -> void:
	audio_player.stop()

func _validate_segments() -> void:
	for i in segments:
		if i.end <= i.start:
			push_error("Segment end must be greater than start: %s" % i)

## Switches the segments
func switch_segments(segment_index: int) -> void:
	if segment_index >= segments.size():
		push_error("No more segments left!")
		return;
		
	if segment_index < 0:
		push_error("Index cannot be negative!")
		return;

	_current_segment = segments[segment_index]

	if _is_situation_valid():
		audio_player.seek(_current_segment.start)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _is_situation_valid():
		if audio_player.get_playback_position() > _current_segment.end:
			if _current_segment.stops_audio:
				stop()
				return
				
			if _current_segment.loops:
				audio_player.seek(_current_segment.start)
			else:
				var next_index: int = segments.find(_current_segment) + 1
				if next_index < segments.size():
					switch_segments(next_index)
				else:
					stop()  # End playback after the last segment

func _is_situation_valid() -> bool:
	return _current_segment and audio_player.playing

