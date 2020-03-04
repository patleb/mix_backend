### References
# https://hunleyd.github.io/posts/PostgreSQL-logging-strftime-and-you
cat >> "$(sun.pg_config_file)" << EOF
log_filename = 'postgresql-%W.log'
log_truncate_on_rotation = on
log_rotation_size = 0
log_rotation_age = 7d
EOF

sun.pg_restart_force
