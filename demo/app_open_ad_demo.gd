extends Control

# Сигналы для App Open рекламы
signal app_open_ad_loaded(ad_id)
signal app_open_ad_failed_to_load(ad_id, error_data)
signal app_open_ad_impression(ad_id)
signal app_open_ad_clicked(ad_id)
signal app_open_ad_showed_full_screen_content(ad_id)
signal app_open_ad_failed_to_show_full_screen_content(ad_id, error_data)
signal app_open_ad_dismissed_full_screen_content(ad_id)

# Плагин AdMob
var _admob_plugin
var _app_open_ad_id = ""
var _is_initialized = false

# Тестовый ID для App Open рекламы
var _test_app_open_ad_id = "ca-app-pub-3940256099942544/9257395921"

# Реальный ID для App Open рекламы (замените на свой)
var _real_app_open_ad_id = "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"

# Флаг для использования тестовых ID
var _use_test_ads = true

@onready var _status_label = $StatusLabel
@onready var _load_button = $VBoxContainer/LoadButton
@onready var _show_button = $VBoxContainer/ShowButton
@onready var _remove_button = $VBoxContainer/RemoveButton

func _ready():
	if Engine.has_singleton("AdmobPlugin"):
		_admob_plugin = Engine.get_singleton("AdmobPlugin")
		
		# Подключаем сигналы инициализации
		_admob_plugin.connect("initialization_completed", _on_initialization_completed)
		
		# Подключаем сигналы App Open рекламы
		_admob_plugin.connect("app_open_ad_loaded", _on_app_open_ad_loaded)
		_admob_plugin.connect("app_open_ad_failed_to_load", _on_app_open_ad_failed_to_load)
		_admob_plugin.connect("app_open_ad_impression", _on_app_open_ad_impression)
		_admob_plugin.connect("app_open_ad_clicked", _on_app_open_ad_clicked)
		_admob_plugin.connect("app_open_ad_showed_full_screen_content", _on_app_open_ad_showed_full_screen_content)
		_admob_plugin.connect("app_open_ad_failed_to_show_full_screen_content", _on_app_open_ad_failed_to_show_full_screen_content)
		_admob_plugin.connect("app_open_ad_dismissed_full_screen_content", _on_app_open_ad_dismissed_full_screen_content)
		
		# Инициализируем плагин
		_admob_plugin.initialize()
		_status_label.text = "Initializing AdMob..."
	else:
		_status_label.text = "AdMob plugin not available!"
		_disable_buttons()

func _disable_buttons():
	_load_button.disabled = true
	_show_button.disabled = true
	_remove_button.disabled = true

func _on_initialization_completed(status):
	_is_initialized = true
	_status_label.text = "AdMob initialized!"
	_load_button.disabled = false

func _on_load_button_pressed():
	if _is_initialized:
		var ad_unit_id = _test_app_open_ad_id if _use_test_ads else _real_app_open_ad_id
		var ad_data = {
			"ad_unit_id": ad_unit_id
		}
		_admob_plugin.load_app_open_ad(ad_data)
		_status_label.text = "Loading App Open ad..."
	else:
		_status_label.text = "AdMob not initialized!"

func _on_show_button_pressed():
	if _app_open_ad_id.is_empty():
		_status_label.text = "No App Open ad loaded!"
	else:
		_admob_plugin.show_app_open_ad(_app_open_ad_id)
		_status_label.text = "Showing App Open ad..."

func _on_remove_button_pressed():
	if _app_open_ad_id.is_empty():
		_status_label.text = "No App Open ad to remove!"
	else:
		_admob_plugin.remove_app_open_ad(_app_open_ad_id)
		_app_open_ad_id = ""
		_status_label.text = "App Open ad removed!"
		_show_button.disabled = true
		_remove_button.disabled = true

# Обработчики сигналов App Open рекламы
func _on_app_open_ad_loaded(ad_id):
	_app_open_ad_id = ad_id
	_status_label.text = "App Open ad loaded: " + ad_id
	_show_button.disabled = false
	_remove_button.disabled = false
	emit_signal("app_open_ad_loaded", ad_id)

func _on_app_open_ad_failed_to_load(ad_id, error_data):
	_status_label.text = "App Open ad failed to load: " + error_data.message
	emit_signal("app_open_ad_failed_to_load", ad_id, error_data)

func _on_app_open_ad_impression(ad_id):
	_status_label.text = "App Open ad impression: " + ad_id
	emit_signal("app_open_ad_impression", ad_id)

func _on_app_open_ad_clicked(ad_id):
	_status_label.text = "App Open ad clicked: " + ad_id
	emit_signal("app_open_ad_clicked", ad_id)

func _on_app_open_ad_showed_full_screen_content(ad_id):
	_status_label.text = "App Open ad showed full screen content: " + ad_id
	emit_signal("app_open_ad_showed_full_screen_content", ad_id)

func _on_app_open_ad_failed_to_show_full_screen_content(ad_id, error_data):
	_status_label.text = "App Open ad failed to show: " + error_data.message
	emit_signal("app_open_ad_failed_to_show_full_screen_content", ad_id, error_data)

func _on_app_open_ad_dismissed_full_screen_content(ad_id):
	_status_label.text = "App Open ad dismissed: " + ad_id
	emit_signal("app_open_ad_dismissed_full_screen_content", ad_id)
