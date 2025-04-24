#!/usr/bin/bash

# Set environment
openrefine_data_dir=${XDG_DATA_HOME}/openrefine
openrefine_conf_dir=${XDG_CONFIG_HOME}/openrefine
openrefine_ini_file=${openrefine_conf_dir}/refine.ini
openrefine_lib_dir="/app/lib/openrefine"
openrefine_env_file="/tmp/refine-config.env"
openrefine_pid_file="/tmp/refine-webapp.pid"
systray_pid_file="/tmp/refine-systray.pid"
systray_image="${openrefine_lib_dir}/webapp/modules/core/images/favicon.png"

function openrefine_config {
    # Check data folder
    if [ ! -d ${openrefine_data_dir} ]; then
        mkdir -p ${openrefine_data_dir}
    fi
    # Check config folder
    if [ ! -d ${openrefine_conf_dir} ]; then
        mkdir -p ${openrefine_conf_dir}
        cp ${openrefine_lib_dir}/refine.ini ${openrefine_ini_file}
    fi
    # Check environment
	if [ -f ${openrefine_ini_file} ]; then
		rm ${openrefine_env_file}
		grep REFINE_HOST ${openrefine_ini_file} >> ${openrefine_env_file}
		grep REFINE_PORT ${openrefine_ini_file} >> ${openrefine_env_file}
		source ${openrefine_env_file}
        rm ${openrefine_env_file}
	fi
	if [ -z "$REFINE_HOST" ]; then
    	REFINE_HOST="localhost"
	fi
	if [ -z "$REFINE_PORT" ]; then
    	REFINE_PORT="3333"
	fi
}

function openrefine_start {
    openrefine_config
    # Run webapp
    export JAVA_HOME=/app/jre
    ${openrefine_lib_dir}/refine -c ${openrefine_ini_file} -d ${openrefine_data_dir} $@ &
    echo $! > ${openrefine_pid_file}
    # Run systray
    if [ ! -f ${systray_pid_file} ]; then
        systray_open_command="xdg-open http://${REFINE_HOST}:${REFINE_PORT}/"
        export GDK_BACKEND=x11
        yad --notification --listen --image="${systray_image}" \
            --command="${systray_open_command}" --text="OpenRefine" \
            --menu="Open! ${systray_open_command} | Quit! openrefine.sh quit" &
        echo $! > ${systray_pid_file}
	fi
}

function openrefine_quit {
	if [ -f ${openrefine_pid_file} ]; then
		kill $(cat ${openrefine_pid_file})
		rm ${openrefine_pid_file}
	fi
	if [ -f ${systray_pid_file} ]; then
		kill $(cat ${systray_pid_file})
		rm ${systray_pid_file}
	fi
}

ACTION="$1"
if [ -z "$ACTION" ] ; then
    ACTION='start'
fi

case "$ACTION" in
  start) openrefine_start;;
  quit)  openrefine_quit;;
  *) echo "Unknown systray command: \"$ACTION\"";;
esac
