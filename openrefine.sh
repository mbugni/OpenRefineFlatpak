#!/usr/bin/bash

# Set environment
export JAVA_HOME=/app/jre
openrefine_data_dir=${XDG_DATA_HOME}/openrefine
openrefine_conf_dir=${XDG_CONFIG_HOME}/openrefine

# Check data folder
if [ ! -d ${openrefine_data_dir} ]
then
    mkdir -p ${openrefine_data_dir}
fi

# Check config folder
if [ ! -d ${openrefine_conf_dir} ]
then
    mkdir -p ${openrefine_conf_dir}
    cp /app/bin/refine.ini ${openrefine_conf_dir}/refine.ini
fi

# Run executable
/app/bin/refine -c ${openrefine_conf_dir}/refine.ini -d ${openrefine_data_dir} $@ &
sleep 3
exec xdg-open http://127.0.0.1:3333/
