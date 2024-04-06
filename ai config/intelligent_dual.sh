plugin_name="intelligent-dual"
plugin_description="Just  work with Pursuit Mode"
plugin_author="Dpehect"

plugin_enabled=1

plugin_minimum_ag_affected_version="10.30"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")


ap_timeout=15

ap_down=2


ap_check=4


intelligent_dual_debug=false


function manage_evil_dual_ap() {

	debug_print

	target_check=1
	access_point_down=0

	while true; do
		current_date="$(date +%s)"
		if grep -Eq "^${bssid}, " "${tmpdir}dos_pm-01.csv" > /dev/null 2>&1; then
			lastseen_date="$(date -d"$(grep -E "^${bssid}, " "${tmpdir}dos_pm-01.csv" | awk -F', ' '{print $3}')" +%s)"
			elapsed_seconds="$(expr "${current_date}" - "${lastseen_date}")"
		else
			elapsed_seconds="${ap_timeout}"
		fi
		if [[ "${intelligent_dual_debug}" = "true" ]]; then
			echo ------------------------
			echo "current time:    $(date -d @${current_date})"
			echo "lastseen time:   $(date -d @${lastseen_date})"
			echo "elapsed seconds: ${elapsed_seconds}"
		fi
		if [[ "${elapsed_seconds}" -lt "${ap_timeout}" ]]; then
			access_point_down=0
			if hostapd_cli status interface "${interface}" 2>/dev/null | grep -q "state=DISABLED"; then
				echo
				if hostapd_cli enable interface "${interface}" > /dev/null 2>&1; then
					language_strings "${language}" "intelligent_dual_text_0" "green"
					if [ "${et_mode}" = "et_captive_portal" ] && ! pgrep -f "${optional_tools_names[12]} -i ${interface} -f ${tmpdir}${hosts_file}" > /dev/null 2>&1; then
						launch_dns_blackhole
					fi
				else
					language_strings "${language}" "intelligent_dual_text_1" "red"
				fi
			fi
		else
			access_point_down="$(expr "${access_point_down}" + 1)"
			if [[ "${access_point_down}" -gt "${ap_down}" ]] && hostapd_cli status interface "${interface}" 2>/dev/null | grep -q "state=ENABLED"; then
				echo
				if hostapd_cli disable interface "${interface}" > /dev/null 2>&1; then
					language_strings "${language}" "intelligent_dual_text_2" "yellow"
				else
					language_strings "${language}" "intelligent_dual_text_3" "red"
				fi
			fi
		fi
		if [[ "${intelligent_dual_debug}" = "true" ]]; then
			echo "consecutive times down: ${access_point_down}"
		fi
		if ! pgrep -f "hostapd ${tmpdir}${current_hostapd_file}" > /dev/null 2>&1; then
			unset target_check
			break
		fi
		if [[ "${intelligent_dual_debug}" = "true" ]]; then
			countdown="$(expr "${ap_check}" + 1)"
			while [[ "${countdown}" -le "$(expr "${ap_check}" + 1)" ]] && [[ "${countdown}" -gt 0 ]]; do
				countdown="$(expr "${countdown}" - 1)"
				echo -en "\r\e[1;35mCheck Target in "${countdown}" seconds...   \e[0m\c"
				sleep 1
			done
			echo
		else
			sleep "${ap_check}"
		fi
	done
}

function intelligent_dual_posthook_exec_et_deauth() {

	debug_print

	if [ "${current_menu}" = "evil_dual_attacks_menu" ] && [ "${dos_pursuit_mode}" -eq 1 ] && ! echo "${target_check}" | grep -xq "1"; then
		manage_evil_dual_ap &
	fi
}

function set_hostapd_config_ctrl_interface() {

	debug_print

	{
	echo -e "ctrl_interface=/var/run/hostapd"
	echo -e "ctrl_interface_group=0"
	} >> "${tmpdir}${current_hostapd_file}"
}

function intelligent_dual_posthook_set_hostapd_config() {

	debug_print

	current_hostapd_file="${hostapd_file}"
	set_hostapd_config_ctrl_interface
}

function intelligent_dual_posthook_set_hostapd_wpe_config() {

	debug_print

	current_hostapd_file="${hostapd_wpe_file}"
	set_hostapd_config_ctrl_interface
}

function initialize_intelligent_dual_language_strings() {

	debug_print

	declare -gA arr
	arr["ENGLISH","intelligent_dual_text_0"]="Target detected, Evil dual AP enabled"
	arr["SPANISH","intelligent_dual_text_0"]="\${pending_of_translation} Objetivo detectado, Evil dual AP habilitado"
	arr["FRENCH","intelligent_dual_text_0"]="\${pending_of_translation} Cible détectée, Evil dual AP activé"
	arr["CATALAN","intelligent_dual_text_0"]="\${pending_of_translation} S'ha detectat l'objectiu: l'AP Evil dual està activada"
	arr["PORTUGUESE","intelligent_dual_text_0"]="\${pending_of_translation} Alvo detectado, Evil dual AP ativado"
	arr["RUSSIAN","intelligent_dual_text_0"]="\${pending_of_translation} Обнаружена цель, включена злая двойная точка доступа"
	arr["GREEK","intelligent_dual_text_0"]="\${pending_of_translation} Εντοπίστηκε στόχος, ενεργοποιήθηκε το Evil dual AP"
	arr["ITALIAN","intelligent_dual_text_0"]="Target rilevato, Evil dual AP abilitato"
	arr["POLISH","intelligent_dual_text_0"]="\${pending_of_translation} Wykryto cel, włączony Zły dual AP"
	arr["GERMAN","intelligent_dual_text_0"]="\${pending_of_translation} Ziel erkannt, Evil dual AP aktiviert"
	arr["TURKISH","intelligent_dual_text_0"]="\${pending_of_translation} Hedef tespit edildi, Evil dual AP etkin"
	arr["ARABIC","intelligent_dual_text_0"]="\${pending_of_translation} تم الكشف عن الهدف ، وتم تمكين نقطة الوصول المزدوجة الشريرة"

	arr["ENGLISH","intelligent_dual_text_1"]="Error enabling Evil dual AP"
	arr["SPANISH","intelligent_dual_text_1"]="\${pending_of_translation} Error al habilitar Evil dual AP"
	arr["FRENCH","intelligent_dual_text_1"]="\${pending_of_translation} Erreur lors de l'activation de Evil dual AP"
	arr["CATALAN","intelligent_dual_text_1"]="\${pending_of_translation} Error en habilitar Evil dual AP"
	arr["PORTUGUESE","intelligent_dual_text_1"]="\${pending_of_translation} Erro ao ativar o Evil dual AP"
	arr["RUSSIAN","intelligent_dual_text_1"]="\${pending_of_translation} Ошибка включения Evil dual AP"
	arr["GREEK","intelligent_dual_text_1"]="\${pending_of_translation} Σφάλμα κατά την ενεργοποίηση του Evil dual AP"
	arr["ITALIAN","intelligent_dual_text_1"]="Errore durante l'attivazione dell'Evil dual AP"
	arr["POLISH","intelligent_dual_text_1"]="\${pending_of_translation} Błąd podczas włączania Evil dual AP"
	arr["GERMAN","intelligent_dual_text_1"]="\${pending_of_translation} Fehler beim Aktivieren des Evil dual AP"
	arr["TURKISH","intelligent_dual_text_1"]="\${pending_of_translation} Evil dual AP etkinleştirilirken hata oluştu"
	arr["ARABIC","intelligent_dual_text_1"]="\${pending_of_translation} خطأ في تمكين نقطة الوصول المزدوجة الشريرة"

	arr["ENGLISH","intelligent_dual_text_2"]="Target not detected, Evil dual AP disabled"
	arr["SPANISH","intelligent_dual_text_2"]="\${pending_of_translation} Objetivo no detectado, Evil dual AP deshabilitado"
	arr["FRENCH","intelligent_dual_text_2"]="\${pending_of_translation} Cible non détectée, Evil dual AP désactivé"
	arr["CATALAN","intelligent_dual_text_2"]="\${pending_of_translation} Objectiu no detectat, desactivat AP Evil dual"
	arr["PORTUGUESE","intelligent_dual_text_2"]="\${pending_of_translation} Alvo não detectado, AP Evil dual desativado"
	arr["RUSSIAN","intelligent_dual_text_2"]="\${pending_of_translation} Цель не обнаружена, злая двойная точка доступа отключена"
	arr["GREEK","intelligent_dual_text_2"]="\${pending_of_translation} Ο στόχος δεν εντοπίστηκε, το Evil dual AP απενεργοποιήθηκε"
	arr["ITALIAN","intelligent_dual_text_2"]="Target non rilevato, Evil dual AP disabilitato"
	arr["POLISH","intelligent_dual_text_2"]="\${pending_of_translation} Nie wykryto celu, Złe Podwójne AP wyłączone"
	arr["GERMAN","intelligent_dual_text_2"]="\${pending_of_translation} Ziel nicht erkannt, Evil dual AP deaktiviert"
	arr["TURKISH","intelligent_dual_text_2"]="\${pending_of_translation} Hedef tespit edilmedi, Evil dual AP devre dışı"
	arr["ARABIC","intelligent_dual_text_2"]="\${pending_of_translation} الهدف لم يتم اكتشافه ، تم تعطيل نقطة الوصول المزدوجة الشريرة"

	arr["ENGLISH","intelligent_dual_text_3"]="Error disabling Evil dual AP"
	arr["SPANISH","intelligent_dual_text_3"]="\${pending_of_translation} Error al deshabilitar Evil dual AP"
	arr["FRENCH","intelligent_dual_text_3"]="\${pending_of_translation} Erreur lors de la désactivation de Evil dual AP"
	arr["CATALAN","intelligent_dual_text_3"]="\${pending_of_translation} Error en desactivar Evil dual AP"
	arr["PORTUGUESE","intelligent_dual_text_3"]="\${pending_of_translation} Erro ao desativar o Evil dual AP"
	arr["RUSSIAN","intelligent_dual_text_3"]="\${pending_of_translation} Ошибка отключения Evil dual AP"
	arr["GREEK","intelligent_dual_text_3"]="\${pending_of_translation} Σφάλμα κατά την απενεργοποίηση του Evil dual AP"
	arr["ITALIAN","intelligent_dual_text_3"]="Errore durante la disabilitazione dell'Evil dual AP"
	arr["POLISH","intelligent_dual_text_3"]="\${pending_of_translation} Błąd podczas wyłączania złego podwójnego AP"
	arr["GERMAN","intelligent_dual_text_3"]="\${pending_of_translation} Fehler beim Deaktivieren des Evil dual AP"
	arr["TURKISH","intelligent_dual_text_3"]="\${pending_of_translation} Evil dual AP devre dışı bırakılırken hata oluştu"
	arr["ARABIC","intelligent_dual_text_3"]="\${pending_of_translation} خطأ في تعطيل نقطة الوصول المزدوجة الشريرة"
}

initialize_intelligent_dual_language_strings
