plugin_name="save_your_own_path"
plugin_description="Set the default directory for saving files"
plugin_author="Dpehect"

plugin_enabled=1

plugin_minimum_ag_affected_version="10.0"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")


save_your_own_path="${scriptfolder}${plugins_dir}output/"

function default_save_path_override_set_default_save_path() {

	debug_print

	lastchar_save_your_own_path=${save_your_own_path: -1}
	if [ "${lastchar_save_your_own_path}" != "/" ]; then
		save_your_own_path="${save_your_own_path}/"
	fi
	
	if [[ ! -d "${save_your_own_path}/" ]]; then
		mkdir -p "${save_your_own_path}/"
		folder_owner="$(ls -ld "${save_your_own_path}.." | awk -F' ' '{print $3}')"
		folder_group="$(ls -ld "${save_your_own_path}.." | awk -F' ' '{print $4}')"
		chown "${folder_owner}":"${folder_group}" -R "${save_your_own_path}"
	fi

	if [ "${is_docker}" -eq 1 ]; then
		default_save_path="${docker_io_dir}"
	else
		default_save_path="${save_your_own_path}"
	fi
}
