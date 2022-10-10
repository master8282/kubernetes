cat ~/kubeconfigs/kubeconf_generator.sh
#!/bin/bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -H|--help)
      cat <<EOF

The script is yaml file generator for local host.

Use "-h", "--host" to specify hostname or IP.
Use "-p", "--port" to specify port. Or default "6553".
Use "-c", "--cert" to spcify the dir with PKI certs.
Or default "./<hostname>/kubernetes/admin/pki/"
Use "-d", "--dir" for place to save the yaml.
Or defaut "./<hostname>/kubeconfig.yaml".
Use "-H", "--help" to display the current text.
EOF
    exit 1
      ;;
    -h|--host)
      HOST="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--port)
      PORT="$2"
      shift # past argument
      shift # past value
      ;;
    -c|--pki-cert)
      CERT="$2"
      shift # past argument
      shift # past value
      ;;
    -d|--dir)
      DIR="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      echo "Use '-H' or '--help' for help."
      exit 1
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [ -z $HOST ]
then
  echo "Error: no hostname or IP were specified."
  echo "Use '-H' or '--help' for help."
  exit 1
fi

if [ -z $PORT ]
then
  PORT=6553
fi

if [ -z $CERT ]
then
  CERT="$(dirname $0)/$HOST/kubernetes/admin/pki/"
fi

if [ -z $DIR ]
then
  DIR="$(dirname $0)/$HOST/kubeconfig.yaml"
else
  DIR="$DIR/kubeconfig.yaml"
fi

#echo "HOST  = ${HOST}"
#echo "PORT  = ${PORT}"
#echo "CERT  = ${CERT}"
#echo "DIR  = ${DIR}"

if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

ccd=$(cat $(dirname $0)/$HOST/kubernetes/admin/pki/admin.pem | base64 -w 0)
ckd=$(cat $(dirname $0)/$HOST/kubernetes/admin/pki/admin-key.pem | base64 -w 0) 

cat >$DIR<<EOF

---
apiVersion: v1
clusters:
- cluster:
    server: https://$HOST:$PORT
    insecure-skip-tls-verify: true
  name: $HOST
contexts:
- context:
    cluster: $HOST
    user: $HOST
  name: $HOST
current-context: $HOST
kind: Config
preferences: {}
users:
- name: $HOST
  user:
    client-certificate-data: $ccd
    client-key-data: $ckd

EOF

cat $DIR
