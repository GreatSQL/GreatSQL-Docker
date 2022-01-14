#!/bin/bash

. /etc/profile.d/mysql.sh

# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
	set -- mysqld "$@"
fi

# skip setup if they want an option that stops mysqld
wantHelp=
for arg; do
	case "$arg" in
		-'?'|--help|--print-defaults|-V|--version)
			wantHelp=1
			break
			;;
	esac
done

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# usage: process_init_file FILENAME MYSQLCOMMAND...
#    ie: process_init_file foo.sh mysql -uroot
# (process a single initializer file, based on its extension. we define this
# function here, so that initializer scripts (*.sh) can use the same logic,
# potentially recursively, or override the logic used in subsequent calls)
process_init_file() {
	local f="$1"; shift
	local mysql=( "$@" )

	case "$f" in
		*.sh)     echo "$0: running $f"; . "$f" ;;
		*.sql)    echo "$0: running $f"; "${mysql[@]}" < "$f"; echo ;;
		*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${mysql[@]}"; echo ;;
		*)        echo "$0: ignoring $f" ;;
	esac
	echo
}

_check_config() {
	toRun=( "$@" --verbose --help )
	if ! errors="$("${toRun[@]}" 2>&1 >/dev/null)"; then
		cat >&2 <<-EOM
			ERROR: mysqld failed while attempting to check config
			command was: "${toRun[*]}"
			$errors
		EOM
		exit 1
	fi
}

# Fetch value from server config
# We use mysqld --verbose --help instead of my_print_defaults because the
# latter only show values present in config files, and not server defaults
_get_config() {
	local conf="$1"; shift
	"$@" --verbose --help --log-bin-index="$(mktemp -u)" 2>/dev/null \
		| awk '$1 == "'"$conf"'" && /^[^ \t]/ { sub(/^[^ \t]+[ \t]+/, ""); print; exit }'
	# match "datadir      /some/path with/spaces in/it here" but not "--xyz=abc\n     datadir (xyz)"
}

if [ "$1" = 'mysqld' -a -z "$wantHelp" ]; then
	# still need to check config, container may have started with --user
	_check_config "$@"

	if [ -n "$INIT_TOKUDB" ]; then
		export LD_PRELOAD=/usr/lib64/libjemalloc.so.1
	fi
	# Get config
	DATADIR="$(_get_config 'datadir' "$@")"

	if [ ! -d "$DATADIR/mysql" ]; then
		file_env 'MYSQL_ROOT_PASSWORD'
		if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" -a -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
			echo >&2 'error: database is uninitialized and password option is not specified '
			echo >&2 '  You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD'
			exit 1
		fi

		file_env 'MYSQL_SID'
		SID=3306$(date +%N%1000|cut -b 1-3)
		if [ "$MYSQL_SID" ] ; then
			sed -i "s/MYSQL_SID/${MYSQL_SID}/ig" /etc/my.cnf
		else
			sed -i "s/MYSQL_SID/${SID}/ig" /etc/my.cnf
		fi

		file_env 'MYSQL_IBP'
		if [ "$MYSQL_IBP" ] ; then
			sed -i "s/MYSQL_IBP/${MYSQL_IBP}/ig" /etc/my.cnf
		else
			sed -i "s/MYSQL_IBP/128M/ig" /etc/my.cnf
		fi

		file_env 'MYSQL_MGR_NAME'
		if [ "$MYSQL_MGR_NAME" ] ; then
			sed -i "s/MYSQL_MGR_NAME/${MYSQL_MGR_NAME}/ig" /etc/my.cnf
		else
			sed -i "s/MYSQL_MGR_NAME/'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1'/ig" /etc/my.cnf
		fi

		file_env 'MYSQL_MGR_LOCAL'
		if [ "${MYSQL_MGR_LOCAL}" ] ; then
			sed -i "s/MYSQL_MGR_LOCAL/${MYSQL_MGR_LOCAL}/ig" /etc/my.cnf
		else
			sed -i "s/MYSQL_MGR_LOCAL/'172.17.0.2:33061'/ig" /etc/my.cnf
		fi

		file_env 'MYSQL_MGR_SEEDS'
		if [ "${MYSQL_MGR_SEEDS}" ] ; then
			sed -i "s/MYSQL_MGR_SEEDS/${MYSQL_MGR_SEEDS}/ig" /etc/my.cnf
		else
			sed -i "s/MYSQL_MGR_SEEDS/'172.17.0.2:33061,172.17.0.3:33061'/ig" /etc/my.cnf
		fi

		mkdir -p "$DATADIR"

		echo 'Initializing database'
		"$@" --initialize-insecure
		echo 'Database initialized'

		if command -v mysql_ssl_rsa_setup > /dev/null && [ ! -e "$DATADIR/server-key.pem" ]; then
			# https://github.com/mysql/mysql-server/blob/23032807537d8dd8ee4ec1c4d40f0633cd4e12f9/packaging/deb-in/extra/mysql-systemd-start#L81-L84
			echo 'Initializing certificates'
			mysql_ssl_rsa_setup --datadir="$DATADIR"
			echo 'Certificates initialized'
		fi

		SOCKET="$(_get_config 'socket' "$@")"
		"$@" --skip-networking --socket="${SOCKET}" &
		pid="$!"

		mysql=( mysql -f --protocol=socket -uroot -hlocalhost --socket="${SOCKET}" --password="" )

		for i in {120..0}; do
			if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
				break
			fi
			echo 'MySQL init process in progress...'
			sleep 1
		done
		if [ "$i" = 0 ]; then
			echo >&2 'MySQL init process failed.'
			exit 1
		fi

		if [ -z "$MYSQL_INITDB_SKIP_TZINFO" ]; then
			(
				echo "SET @@SESSION.SQL_LOG_BIN = off;"
				# sed is for https://bugs.mysql.com/bug.php?id=20545
				mysql_tzinfo_to_sql /usr/share/zoneinfo | sed 's/Local time zone must be set--see zic manual page/FCTY/'
			) | "${mysql[@]}" mysql
		fi

		if [ ! -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
			MYSQL_ROOT_PASSWORD="$(pwmake 128)"
			echo "GENERATED ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
		fi

		rootCreate=
		# default root to listen for connections from anywhere
		file_env 'MYSQL_ROOT_HOST' '%'
		if [ ! -z "$MYSQL_ROOT_HOST" -a "$MYSQL_ROOT_HOST" != 'localhost' ]; then
			# no, we don't care if read finds a terminating character in this heredoc
			# https://unix.stackexchange.com/questions/265149/why-is-set-o-errexit-breaking-this-read-heredoc-expression/265151#265151
			read -r -d '' rootCreate <<-EOSQL || true
				CREATE USER 'root'@'${MYSQL_ROOT_HOST}' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
				GRANT ALL ON *.* TO 'root'@'${MYSQL_ROOT_HOST}' WITH GRANT OPTION ;
			EOSQL
		fi

		mgrInit=
		if [ "${MYSQL_INIT_MGR}" ]; then
			#if [ -z "${MYSQL_MGR_USER_PWD}" -o -z "${MYSQL_MGR_USER}" ] ; then
			#	echo >&2 'You need to specify MYSQL_MGR_USER and MYSQL_MGR_USER_PWD when MYSQL_INIT_MGR=1'
			#	exit 1
			#fi
			if [ -z "${MYSQL_MGR_USER}" ] ; then
				MYSQL_MGR_USER='repl'
			fi

			if [ -z "${MYSQL_MGR_USER_PWD}" ] ; then
				MYSQL_MGR_USER_PWD='repl4MGR'
			fi

			read -r -d '' mgrInit <<-EOSQL || true
				CREATE USER ${MYSQL_MGR_USER} IDENTIFIED WITH mysql_native_password BY '${MYSQL_MGR_USER_PWD}';
				GRANT REPLICATION SLAVE, BACKUP_ADMIN ON *.* TO ${MYSQL_MGR_USER};
				CHANGE MASTER TO MASTER_USER='${MYSQL_MGR_USER}', MASTER_PASSWORD='${MYSQL_MGR_USER_PWD}' FOR CHANNEL 'group_replication_recovery';
				RESET MASTER;
			EOSQL
		fi

		"${mysql[@]}" <<-EOSQL
			-- What's done in this file shouldn't be replicated
			--  or products like mysql-fabric won't work
			SET @@SESSION.SQL_LOG_BIN=0;
			DELETE FROM mysql.user WHERE user NOT IN ('mysql.sys', 'mysqlxsys', 'mysql.infoschema', 'mysql.session', 'root') OR host NOT IN ('localhost') ;
			ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
			GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION ;
			${rootCreate}
			${mgrInit}
			DROP DATABASE IF EXISTS test ;
			FLUSH PRIVILEGES ;
		EOSQL

		if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
			mysql+=( -p"${MYSQL_ROOT_PASSWORD}" )
		fi

		file_env 'MYSQL_DATABASE'
		if [ "$MYSQL_DATABASE" ]; then
			echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"
			mysql+=( "$MYSQL_DATABASE" )
		fi

		file_env 'MYSQL_USER'
		file_env 'MYSQL_PASSWORD'
		if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
			echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" | "${mysql[@]}"

			if [ "$MYSQL_DATABASE" ]; then
				echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" | "${mysql[@]}"
			fi

			echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"
		fi

		echo
		ls /docker-entrypoint-initdb.d/ > /dev/null
		for f in /docker-entrypoint-initdb.d/*; do
			process_init_file "$f" "${mysql[@]}"
		done

		if [ ! -z "$MYSQL_ONETIME_PASSWORD" ]; then
			"${mysql[@]}" <<-EOSQL
				ALTER USER 'root'@'%' PASSWORD EXPIRE;
			EOSQL
		fi
		if ! kill -s TERM "$pid" || ! wait "$pid"; then
			echo >&2 'MySQL init process failed.'
			exit 1
		fi

		echo
		echo 'MySQL init process done. Ready for start up.'
		echo
	fi

  # exit when MYSQL_INIT_ONLY environment variable is set to avoid starting mysqld
  if [ ! -z "$MYSQL_INIT_ONLY" ]; then
      echo 'Initialization complete, now exiting!'
      exit 0
  fi
fi

exec "$@"
