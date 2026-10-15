@tool
extends EditorPlugin
## Puts the DrawPetsNearby Android plugin into Android exports: the AAR built from
## android_plugin/ (copied into bin/ by its Gradle build) and the libraries it needs.
## Editor only - the game reaches the plugin through Engine.get_singleton("DrawPetsNearby").
## Android plugins need "Use Gradle Build" on in the export preset (.ai/android.md).

var _export: DrawPetsNearbyExport


func _enter_tree() -> void:
	_export = DrawPetsNearbyExport.new()
	add_export_plugin(_export)


func _exit_tree() -> void:
	remove_export_plugin(_export)
	_export = null


class DrawPetsNearbyExport extends EditorExportPlugin:
	const PLUGIN := "DrawPetsNearby"
	## An AAR does not carry its dependencies, so the game's Gradle build fetches this itself.
	## Keep in step with nearbyVersion in android_plugin/plugin/build.gradle.
	const NEARBY := "com.google.android.gms:play-services-nearby:19.5.1"
	## The swap-code scanner: ZXing's camera screen. Keep in step with scannerVersion.
	const SCANNER := "com.journeyapps:zxing-android-embedded:4.3.0"

	func _get_name() -> String:
		return PLUGIN

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	## Relative to res://addons/.
	func _get_android_libraries(_platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		var variant := "debug" if debug else "release"
		return PackedStringArray(["drawpets_nearby/bin/%s-%s.aar" % [PLUGIN, variant]])

	func _get_android_dependencies(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		return PackedStringArray([NEARBY, SCANNER])
