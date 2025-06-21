q_MONGO_USER=`jq --arg v "$MONGO_USER" -n '$v'`
q_MONGO_PASS=`jq --arg v "$MONGO_PASS" -n '$v'`
mongo -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" admin <<EOF
    db.getSiblingDB("unifi").createUser({
        user: $q_MONGO_USER,
        pwd: $q_MONGO_PASS,
        roles: [
            { role: "dbOwner", db: "unifi" },
            { role: "dbOwner", db: "unifi_audit" },
            { role: "dbOwner", db: "unifi_stat" },
        ],
    });
EOF
