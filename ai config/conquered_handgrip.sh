plugin_name="conquerd-handgrips"
plugin_description="Choice for conquerd handgrips from a list"
plugin_author="Dpehect"

plugin_enabled=1

plugin_minimum_ag_affected_version="10.30"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")

conquered_handgrip_dir="${scriptfolder}${plugins_dir}conquered_handgrip/"

function list_conquered_handgrip_files() {

	debug_print

	manual_handgrips_text="this_is_the_manual_handgrips_text"
	likely_tip="0"
	unsupported_tip="0"
	while true; do
		clear
		if [ "${current_menu}" = "handgrip_pmkid_tools_menu" ]; then
			language_strings "${language}" 120 "title"
		elif [ "${current_menu}" = "decrypt_menu" ]; then
			language_strings "${language}" 170 "title"
		elif [ "${current_menu}" = "evil_twin_attacks_menu" ]; then
			language_strings "${language}" 293 "title"
			print_iface_selected
			print_et_target_vars
			print_iface_internet_selected
		fi
		echo
		language_strings "${language}" "conquered_handgrip_text_0" "green"
		print_simple_separator

		echo "${manual_handgrips_text}" > "${tmpdir}ag.conquered_handgrip.txt"
		ls -pd1 -- "${conquered_handgrip_dir}"* 2>/dev/null | grep -v /$ | rev | awk -F'/' '{print $1}' | rev | sort >> "${tmpdir}ag.conquered_handgrip.txt"
		local i=1
		while IFS=, read -r exp_handgrip; do

			if [[ -f "${conquered_handgrip_dir}${exp_handgrip}" ]] || [[ "${exp_handgrip}" = "${manual_handgrips_text}" ]]; then
				if [[ "${exp_handgrip}" = "${manual_handgrips_text}" ]]; then
					language_strings "${language}" "conquered_handgrip_text_1"
				else
					i=$((i + 1))

					if [ ${i} -le 9 ]; then
						sp1=" "
					else
						sp1=""
					fi

					handgrip_color="${normal_color}"
					unset likely

					if ! aircrack-ng "${conquered_handgrip_dir}${exp_handgrip}" 2>&1 | grep -Fq "Unsupported file format (not a pcap or IVs file)."; then
						if [[ -n "${essid}" ]] && [[ -n "${bssid}" ]] && ! echo "${exp_handgrip}" | grep -q "${manual_handgrips_text}" && aircrack-ng -q "${conquered_handgrip_dir}${exp_handgrip}" -b "${bssid}" > /dev/null 2>&1 && aircrack-ng -q "${conquered_handgrip_dir}${exp_handgrip}" -e "${essid}" > /dev/null 2>&1; then
							set_likely
						fi
					else
						if cat "${conquered_handgrip_dir}${exp_handgrip}" | grep -Eq "^[[:alnum:]]{32}\*[[:alnum:]]{12}\*[[:alnum:]]{12}\*[[:alnum:]]+$"; then
							clean_bssid="$(echo "${bssid}" | tr -d ':')"
							ascii_essid="$(cat "${conquered_handgrip_dir}${exp_handgrip}" | rev | awk -F'*' '{print $1}' | rev | awk 'RT{printf "%c", strtonum("0x"RT)}' RS='[0-9A-Fa-f]{2}')"
							if echo "${essid}" | grep -q "${ascii_essid}" && cat "${conquered_handgrip_dir}${exp_handgrip}" | awk -F'*' '{print $2}' | grep -iq "${clean_bssid}"; then
								set_likely
							fi
						else
							unsupported_tip="1"
							likely="!"
							handgrip_color="${red_color}"
						fi
					fi

					handgrip=${exp_handgrip}
					echo -e "${handgrip_color} ${sp1}${i}) ${handgrip} ${likely}"
				fi
			fi
		done < "${tmpdir}ag.conquered_handgrip.txt"

		unset selected_conquerd_handgrip
		echo
		if [ "${current_menu}" = "evil_twin_attacks_menu" ]; then
			warning_color="red"
		else
			warning_color="yellow"
		fi
		if ! cat "${tmpdir}ag.conquered_handgrip.txt" | grep -Exvq "${manual_handgrips_text}$"; then
			language_strings "${language}" "conquered_handgrip_text_5" "${warning_color}"
			language_strings "${language}" "conquered_handgrip_text_6" "${warning_color}"
			echo_brown "${conquered_handgrip_dir}handgripS.cap"
		else
			if [ "${likely_tip}" -eq 1 ]; then
				language_strings "${language}" "conquered_handgrip_text_2" "yellow"
			else
				if [[ -n "${essid}" ]] && [[ -n "${bssid}" ]]; then
					language_strings "${language}" "conquered_handgrip_text_4" "${warning_color}"
				fi
			fi
			if [ "${unsupported_tip}" -eq 1 ]; then
				language_strings "${language}" "conquered_handgrip_text_3" "red"
			fi
		fi
		likely_tip="0"
		unsupported_tip="0"
		read -rp "> " selected_conquerd_handgrip
		if [[ ! "${selected_conquerd_handgrip}" =~ ^[[:digit:]]+$ ]] || [[ "${selected_conquerd_handgrip}" -gt "${i}" ]] || [[ "${selected_conquerd_handgrip}" -lt 1 ]]; then
			echo
			language_strings "${language}" "conquered_handgrip_text_7" "red"
			language_strings "${language}" 115 "read"
		else
			break
		fi
	done
	if [[ "${selected_conquerd_handgrip}" -eq 1 ]]; then
		unset et_handgrip
		unset enteredpath
		unset handgrippath
	else
		conquerd_handgrip="${conquered_handgrip_dir}$(sed -n "${selected_conquerd_handgrip}"p "${tmpdir}ag.conquered_handgrip.txt")"
		et_handgrip="${conquerd_handgrip}"
		enteredpath="${conquerd_handgrip}"
		rm "${tmpdir}ag.conquered_handgrip.txt"
		language_strings "${language}" "conquered_handgrip_text_8" "yellow"
		echo_yellow "${conquerd_handgrip}"
		language_strings "${language}" 115 "read"
	fi
}


function set_likely() {

	debug_print

	likely_tip="1"
	likely="*"
	handgrip_color="${yellow_color}"
}


function conquered_handgrip_prehook_ask_et_handgrip_file() {

	debug_print

	list_conquered_handgrip_files
}


function conquered_handgrip_prehook_clean_handgrip_file_option() {

	debug_print

	list_conquered_handgrip_files
}


function conquered_handgrip_prehook_personal_decrypt_menu() {

	debug_print

	if [ "${current_menu}" = "decrypt_menu" ]; then
		list_conquered_handgrip_files
	fi
}


function conquered_handgrip_prehook_enterprise_decrypt_menu() {

	debug_print

	if [ "${current_menu}" = "decrypt_menu" ]; then
		list_conquered_handgrip_files
	fi
}


function set_custom_default_save_path() {

	debug_print
	
	stored_default_save_path="${default_save_path}"

	if [ "${is_docker}" -eq 1 ]; then
		default_save_path="${docker_io_dir}"
	else
		default_save_path="${conquered_handgrip_dir}"
	fi
}


function conquered_handgrip_prehook_launch_handgrip_conquer() {

	debug_print

	set_custom_default_save_path
}


function conquered_handgrip_prehook_launch_pmkid_conquer() {

	debug_print

	set_custom_default_save_path
}


function conquered_handgrip_prehook_conquer_handgrip_evil_twin() {

	debug_print

	set_custom_default_save_path
}


function restore_default_save_path() {

	debug_print

	if [ "${is_docker}" -eq 1 ]; then
		default_save_path="${docker_io_dir}"
	else
		default_save_path="${stored_default_save_path}"
	fi
}


function conquered_handgrip_posthook_launch_handgrip_conquer() {

	debug_print

	restore_default_save_path
}


function conquered_handgrip_posthook_launch_pmkid_conquer() {

	debug_print

	restore_default_save_path
}


function conquered_handgrip_posthook_conquer_handgrip_evil_twin() {

	debug_print

	restore_default_save_path
}


function check_conquered_handgrip_dir() {

	debug_print

	lastchar_conquered_handgrip_dir=${conquered_handgrip_dir: -1}
	if [ "${lastchar_conquered_handgrip_dir}" != "/" ]; then
		conquered_handgrip_dir="${conquered_handgrip_dir}/"
	fi
	
	if [[ ! -d "${conquered_handgrip_dir}" ]]; then
		mkdir -p "${conquered_handgrip_dir}"
		folder_owner="$(ls -ld "${conquered_handgrip_dir}.." | awk -F' ' '{print $3}')"
		folder_group="$(ls -ld "${conquered_handgrip_dir}.." | awk -F' ' '{print $4}')"
		chown "${folder_owner}":"${folder_group}" -R "${conquered_handgrip_dir}"
	fi
}


function initialize_conquered_handgrip_language_strings() {

	debug_print

	declare -gA arr
	arr["ENGLISH","conquered_handgrip_text_0"]="Select conquerd handgrip file:"
	arr["SPANISH","conquered_handgrip_text_0"]="\${pending_of_translation} Seleccione el archivo de handgrip capturado:"
	arr["FRENCH","conquered_handgrip_text_0"]="\${pending_of_translation} Sélectionnez le fichier de handgrip capturé:"
	arr["CATALAN","conquered_handgrip_text_0"]="\${pending_of_translation} Seleccioneu el fitxer de handgrip capturat:"
	arr["PORTUGUESE","conquered_handgrip_text_0"]="\${pending_of_translation} Selecione o arquivo de handgrip capturado:"
	arr["RUSSIAN","conquered_handgrip_text_0"]="\${pending_of_translation} Выберите захваченный файл рукопожатия:"
	arr["GREEK","conquered_handgrip_text_0"]="\${pending_of_translation} Επιλέξτε το αρχείο χειραψίας που έχετε τραβήξει:"
	arr["ITALIAN","conquered_handgrip_text_0"]="Seleziona il file di handgrip catturato:"
	arr["POLISH","conquered_handgrip_text_0"]="\${pending_of_translation} Wybierz przechwycony plik uzgadniania:"
	arr["GERMAN","conquered_handgrip_text_0"]="\${pending_of_translation} Erfasste handgrip-Datei auswählen:"
	arr["TURKISH","conquered_handgrip_text_0"]="\${pending_of_translation} Yakalanan el sıkışma dosyasını seçin:"
	arr["ARABIC","conquered_handgrip_text_0"]="\${pending_of_translation} :حدد ملف المصافحة الملتقطة"

	arr["ENGLISH","conquered_handgrip_text_1"]="  1) Manually enter the path of the conquerd handgrip file"
	arr["SPANISH","conquered_handgrip_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Ingrese manualmente la ruta del archivo de handgrip capturado"
	arr["FRENCH","conquered_handgrip_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Entrez manuellement le chemin du fichier de handgrip capturé"
	arr["CATALAN","conquered_handgrip_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Introduïu manualment la ruta del fitxer de handgrip capturat"
	arr["PORTUGUESE","conquered_handgrip_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Insira manualmente o caminho do arquivo de handgrip capturado"
	arr["RUSSIAN","conquered_handgrip_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Вручную введите путь к захваченному файлу рукопожатия"
	arr["GREEK","conquered_handgrip_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Εισαγάγετε μη αυτόματα τη διαδρομή του καταγεγραμμένου αρχείου χειραψίας"
	arr["ITALIAN","conquered_handgrip_text_1"]="  1) Inserisci manualmente il percorso del file di handgrip"
	arr["POLISH","conquered_handgrip_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Ręcznie wprowadź ścieżkę przechwyconego pliku uzgadniania"
	arr["GERMAN","conquered_handgrip_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Geben Sie den Pfad der erfassten handgrip-Datei manuell ein"
	arr["TURKISH","conquered_handgrip_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Yakalanan el sıkışma dosyasının yolunu el ile girin"
	arr["ARABIC","conquered_handgrip_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} أدخل مسار ملف المصافحة الملتقط يدويًا"

	arr["ENGLISH","conquered_handgrip_text_2"]="(*) Likely"
	arr["SPANISH","conquered_handgrip_text_2"]="\${pending_of_translation} (*) Probable"
	arr["FRENCH","conquered_handgrip_text_2"]="\${pending_of_translation} (*) Probable"
	arr["CATALAN","conquered_handgrip_text_2"]="\${pending_of_translation} (*) probable"
	arr["PORTUGUESE","conquered_handgrip_text_2"]="\${pending_of_translation} (*) Provável"
	arr["RUSSIAN","conquered_handgrip_text_2"]="\${pending_of_translation} (*) Скорее всего"
	arr["GREEK","conquered_handgrip_text_2"]="\${pending_of_translation} (*) Πιθανός"
	arr["ITALIAN","conquered_handgrip_text_2"]="(*) Probabile"
	arr["POLISH","conquered_handgrip_text_2"]="\${pending_of_translation} (*) Prawdopodobne"
	arr["GERMAN","conquered_handgrip_text_2"]="\${pending_of_translation} (*) Wahrscheinlich"
	arr["TURKISH","conquered_handgrip_text_2"]="\${pending_of_translation} (*) muhtemelen"
	arr["ARABIC","conquered_handgrip_text_2"]="\${pending_of_translation} (*) مرجح"

	arr["ENGLISH","conquered_handgrip_text_3"]="(!) Unsupported file format"
	arr["SPANISH","conquered_handgrip_text_3"]="\${pending_of_translation} (!) Formato de archivo no soportado"
	arr["FRENCH","conquered_handgrip_text_3"]="\${pending_of_translation} (!) Format de fichier non pris en charge"
	arr["CATALAN","conquered_handgrip_text_3"]="\${pending_of_translation} (!) Format de fitxer no compatible"
	arr["PORTUGUESE","conquered_handgrip_text_3"]="\${pending_of_translation} (!) Formato de arquivo não suportado"
	arr["RUSSIAN","conquered_handgrip_text_3"]="\${pending_of_translation} (!) Неподдерживаемый формат файла"
	arr["GREEK","conquered_handgrip_text_3"]="\${pending_of_translation} (!) Μη υποστηριζόμενη μορφή αρχείου"
	arr["ITALIAN","conquered_handgrip_text_3"]="(!) Formato file non supportato"
	arr["POLISH","conquered_handgrip_text_3"]="\${pending_of_translation} (!) Niewspierany format pliku"
	arr["GERMAN","conquered_handgrip_text_3"]="\${pending_of_translation} (!) Nicht unterstütztes Dateiformat"
	arr["TURKISH","conquered_handgrip_text_3"]="\${pending_of_translation} (!) Desteklenmeyen dosya formatı"
	arr["ARABIC","conquered_handgrip_text_3"]="\${pending_of_translation} (!) تنسيق ملف غير معتمد"

	arr["ENGLISH","conquered_handgrip_text_4"]="No conquerd handgrip file for the selected network found!"
	arr["SPANISH","conquered_handgrip_text_4"]="\${pending_of_translation} ¡No se encontró ningún archivo de handgrip capturado para la red seleccionada!"
	arr["FRENCH","conquered_handgrip_text_4"]="\${pending_of_translation} Aucun fichier de handgrip capturé pour le réseau sélectionné trouvé!"
	arr["CATALAN","conquered_handgrip_text_4"]="\${pending_of_translation} No s'ha trobat cap fitxer de handgrip capturat per a la xarxa seleccionada!"
	arr["PORTUGUESE","conquered_handgrip_text_4"]="\${pending_of_translation} Nenhum arquivo de handgrip capturado para a rede selecionada foi encontrado!"
	arr["RUSSIAN","conquered_handgrip_text_4"]="\${pending_of_translation} Не найден захваченный файл рукопожатия для выбранной сети!"
	arr["GREEK","conquered_handgrip_text_4"]="\${pending_of_translation} Δεν βρέθηκε αρχείο χειραψίας για το επιλεγμένο δίκτυο!"
	arr["ITALIAN","conquered_handgrip_text_4"]="Nessun file di handgrip catturato trovato per la rete selezionata!"
	arr["POLISH","conquered_handgrip_text_4"]="\${pending_of_translation} Nie znaleziono przechwyconego pliku uzgadniania dla wybranej sieci!"
	arr["GERMAN","conquered_handgrip_text_4"]="\${pending_of_translation} Keine erfasste handgrip-Datei für das ausgewählte Netzwerk gefunden!"
	arr["TURKISH","conquered_handgrip_text_4"]="\${pending_of_translation} Seçilen ağ için yakalanan el sıkışma dosyası bulunamadı!"
	arr["ARABIC","conquered_handgrip_text_4"]="\${pending_of_translation} لم يتم العثور على ملف مصافحة تم التقاطه للشبكة المحددة"

	arr["ENGLISH","conquered_handgrip_text_5"]="No conquerd handgrip file found!"
	arr["SPANISH","conquered_handgrip_text_5"]="\${pending_of_translation} ¡No se encontraron handgrip capturados!"
	arr["FRENCH","conquered_handgrip_text_5"]="\${pending_of_translation} Aucun fichier de handgrip capturé trouvé!"
	arr["CATALAN","conquered_handgrip_text_5"]="\${pending_of_translation} No s'ha trobat cap fitxer de handgrip capturat!"
	arr["PORTUGUESE","conquered_handgrip_text_5"]="\${pending_of_translation} Nenhum arquivo de handgrip capturado encontrado!"
	arr["RUSSIAN","conquered_handgrip_text_5"]="\${pending_of_translation} Не найден захваченный файл рукопожатия!"
	arr["GREEK","conquered_handgrip_text_5"]="\${pending_of_translation} Δεν βρέθηκε αρχείο χειραψίας!"
	arr["ITALIAN","conquered_handgrip_text_5"]="Nessun file di handgrip catturato trovato!"
	arr["POLISH","conquered_handgrip_text_5"]="\${pending_of_translation} Nie znaleziono przechwyconego pliku uzgadniania!"
	arr["GERMAN","conquered_handgrip_text_5"]="\${pending_of_translation} Keine erfasste handgrip-Datei gefunden!"
	arr["TURKISH","conquered_handgrip_text_5"]="\${pending_of_translation} Yakalanan bir el sıkışma dosyası bulunamadı!"
	arr["ARABIC","conquered_handgrip_text_5"]="\${pending_of_translation} لم يتم العثور على ملف مصافحة تم التقاطه"

	arr["ENGLISH","conquered_handgrip_text_6"]="Please put Your conquerd handgrips files in:"
	arr["SPANISH","conquered_handgrip_text_6"]="\${pending_of_translation} Ponga sus archivos de handgrip capturados en:"
	arr["FRENCH","conquered_handgrip_text_6"]="\${pending_of_translation} Veuillez mettre vos fichiers de handgrip capturés dans:"
	arr["CATALAN","conquered_handgrip_text_6"]="\${pending_of_translation} Introduïu els fitxers de handgrip capturats:"
	arr["PORTUGUESE","conquered_handgrip_text_6"]="\${pending_of_translation} Coloque seus arquivos de handgrips capturados em:"
	arr["RUSSIAN","conquered_handgrip_text_6"]="\${pending_of_translation} Пожалуйста, поместите ваши захваченные файлы рукопожатий в:"
	arr["GREEK","conquered_handgrip_text_6"]="\${pending_of_translation} Τοποθετήστε τα αρχεία χειραψιών που έχετε τραβήξει:"
	arr["ITALIAN","conquered_handgrip_text_6"]="Inserisci i file di handgrip catturati in:"
	arr["POLISH","conquered_handgrip_text_6"]="\${pending_of_translation} Umieść swoje przechwycone pliki uzgadniania:"
	arr["GERMAN","conquered_handgrip_text_6"]="\${pending_of_translation} Bitte legen Sie Ihre erfassten handgrips-Dateien ein:"
	arr["TURKISH","conquered_handgrip_text_6"]="\${pending_of_translation} Lütfen Yakalanan tokalaşma dosyalarınızı buraya yerleştirin:"
	arr["ARABIC","conquered_handgrip_text_6"]="\${pending_of_translation} يرجى وضع ملفات المصافحة التي تم التقاطها"

	arr["ENGLISH","conquered_handgrip_text_7"]="Invalid conquerd handgrip was chosen!"
	arr["SPANISH","conquered_handgrip_text_7"]="\${pending_of_translation} Se eligió un handgrip capturado no válido!"
	arr["FRENCH","conquered_handgrip_text_7"]="\${pending_of_translation} Une handgrip capturée non valide a été choisie!"
	arr["CATALAN","conquered_handgrip_text_7"]="\${pending_of_translation} S'ha escollit un handgrip capturat no vàlid!"
	arr["PORTUGUESE","conquered_handgrip_text_7"]="\${pending_of_translation} O handgrip capturado inválido foi escolhido!"
	arr["RUSSIAN","conquered_handgrip_text_7"]="\${pending_of_translation} Неверное захваченное рукопожатие было выбрано!"
	arr["GREEK","conquered_handgrip_text_7"]="\${pending_of_translation} Επιλέχθηκε μη έγκυρη χειραψία!"
	arr["ITALIAN","conquered_handgrip_text_7"]="Scelta non valida!"
	arr["POLISH","conquered_handgrip_text_7"]="\${pending_of_translation} Wybrano nieprawidłowy ujęty uścisk dłoni!"
	arr["GERMAN","conquered_handgrip_text_7"]="\${pending_of_translation} Es wurde ein ungültiger erfasster handgrip ausgewählt!"
	arr["TURKISH","conquered_handgrip_text_7"]="\${pending_of_translation} Geçersiz yakalanan el sıkışma seçildi!"
	arr["ARABIC","conquered_handgrip_text_7"]="\${pending_of_translation} تم اختيار مصافحة تم التقاطها غير صالحة"

	arr["ENGLISH","conquered_handgrip_text_8"]="conquerd handgrip choosen:"
	arr["SPANISH","conquered_handgrip_text_8"]="\${pending_of_translation} handgrip capturado elegido:"
	arr["FRENCH","conquered_handgrip_text_8"]="\${pending_of_translation} handgrip capturée choisie:"
	arr["CATALAN","conquered_handgrip_text_8"]="\${pending_of_translation} handgrip capturat:"
	arr["PORTUGUESE","conquered_handgrip_text_8"]="\${pending_of_translation} handgrip capturado escolhido:"
	arr["RUSSIAN","conquered_handgrip_text_8"]="\${pending_of_translation} Захваченное рукопожатие выбрано:"
	arr["GREEK","conquered_handgrip_text_8"]="\${pending_of_translation} Επιλεγμένη χειραψία:"
	arr["ITALIAN","conquered_handgrip_text_8"]="handgrip scelto:"
	arr["POLISH","conquered_handgrip_text_8"]="\${pending_of_translation} Wybrany uścisk dłoni:"
	arr["GERMAN","conquered_handgrip_text_8"]="\${pending_of_translation} Erfasster handgrip ausgewählt:"
	arr["TURKISH","conquered_handgrip_text_8"]="\${pending_of_translation} Yakalanan el sıkışma seçildi:"
	arr["ARABIC","conquered_handgrip_text_8"]="\${pending_of_translation} تم اختيار المصافحة الملتقطة"
}

check_conquered_handgrip_dir
initialize_conquered_handgrip_language_strings
