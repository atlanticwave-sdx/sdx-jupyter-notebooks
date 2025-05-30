#/bin/bash

#
# Reference: https://sdx-docs.readthedocs.io/en/latest/sdx_deploy_single_server.html#testing
#


ACTION=$1
WORK_DIR=$2 # ~/awsdx

REPO_URL='https://github.com/atlanticwave-sdx/sdx-continuous-development'
REPO_NAME='sdx-continuous-development'


case "$1" in

'deploy')
echo -e "\n--- Clone\n\n"
[ ! -d ${WORK_DIR} ] && mkdir -p ${WORK_DIR}
cd ${WORK_DIR}
git clone ${REPO_URL}
cd ${REPO_NAME}/data-plane
git checkout main
git pull

echo -e "\n--- Env file\n\n"
cp template.env .env

echo -e "\n--- Build Containers\n\n"
for repo in sdx-lc sdx-controller kytos-sdx; do 
  git -C $repo pull || git clone https://github.com/atlanticwave-sdx/$repo
  cd $repo/
  docker build -t $repo .
  cd ..
done

echo -e "\n--- Docker compose up\n\n"
docker compose up -d
;;


'start')
cd ${WORK_DIR}/sdx-continuous-development/data-plane
docker compose up -d
;;


'stop')
cd ${WORK_DIR}/sdx-continuous-development/data-plane
docker compose down
;;


'oxp_switch_enable')
cd ${WORK_DIR}/sdx-continuous-development/data-plane
./scripts/curl/2.enable_all.sh
;;


'oxp_query_switches')
for i in 8181 8282 8383; do 
echo -e "\n--- $i\n"; curl -s http://0.0.0.0:${i}/api/kytos/topology/v3/switches | jq -r '.switches[].id'; 
done 
;;


'oxp_query_switches_detail')
for i in 8181 8282 8383; do 
echo -e "\n--- $i\n"; curl -s http://0.0.0.0:${i}/api/kytos/topology/v3/switches | jq -r ; 
done 
;;


'oxp_query_mef_eline')
for i in 8181 8282 8383; do 
echo -e "\n--- $i\n"; curl -s http://0.0.0.0:${i}/api/kytos/mef_eline/v2/evc/ | jq -r '.[] | .id + " active=" + (.active|tostring) + " uni_a=" + (.uni_a|tostring) + " uni_z=" + (.uni_z|tostring)'; 
done
;;


'sdx_query_topology')
echo -e "\n--- $i\n"; curl -s http://0.0.0.0:8080/SDX-Controller/topology | jq -r '.nodes[] | (.ports[] | .id)' 
;;


'sdx_query_links')
echo -e "\n--- $i\n"; curl -s http://0.0.0.0:8080/SDX-Controller/topology | jq -r '.links[] | .id + " " + .ports[0] + " " + .ports[1]'
;;

'mininet_ovs_vsctl_show')
cd ${WORK_DIR}/sdx-continuous-development/data-plane
docker compose exec -it mininet ovs-vsctl show
;;


'oxp_create_service_1')
cd ${WORK_DIR}/sdx-continuous-development/data-plane
curl -s -X POST -H 'Content-type: application/json' http://0.0.0.0:8080/SDX-Controller/l2vpn/1.0 -d '{"name": "VLAN between AMPATH/201 and TENET/201", "endpoints": [{"port_id": "urn:sdx:port:ampath.net:Ampath3:50", "vlan": "201"}, {"port_id": "urn:sdx:port:tenet.ac.za:Tenet03:50", "vlan": "201"}]}'
;;


'oxp_create_service_2')
cd ${WORK_DIR}/sdx-continuous-development/data-plane
curl -s -X POST -H 'Content-type: application/json' http://0.0.0.0:8080/SDX-Controller/l2vpn/1.0 -d '{"name": "VLAN between AMPATH/107 and TENET/107", "endpoints": [{"port_id": "urn:sdx:port:ampath.net:Ampath3:50", "vlan": "107"}, {"port_id": "urn:sdx:port:tenet.ac.za:Tenet03:50", "vlan": "107"}]}'
;;


'test_traffic')
cd ${WORK_DIR}
script -c './sdx-continuous-development/data-plane/scripts/curl/config_hosts_and_test.sh' /dev/null
#script -c '${WORK_DIR}/sdx-continuous-development/data-plane/scripts/curl/config_hosts_and_test.sh' /tmp/test-traffic.log
;;

'wait_for_oxp_bootup')
cd ${WORK_DIR}
EXP_SW=3; while true; do N_SW=$(curl -s http://0.0.0.0:8181/api/kytos/topology/v3/switches | jq -r '.switches[].id' | wc -l); echo "waiting switches $N_SW / $EXP_SW"; if [ $N_SW -eq $EXP_SW ]; then break; fi; sleep 1; done
EXP_SW=2; while true; do N_SW=$(curl -s http://0.0.0.0:8282/api/kytos/topology/v3/switches | jq -r '.switches[].id' | wc -l); echo "waiting switches $N_SW / $EXP_SW"; if [ $N_SW -eq $EXP_SW ]; then break; fi; sleep 1; done
EXP_SW=3; while true; do N_SW=$(curl -s http://0.0.0.0:8383/api/kytos/topology/v3/switches | jq -r '.switches[].id' | wc -l); echo "waiting switches $N_SW / $EXP_SW"; if [ $N_SW -eq $EXP_SW ]; then break; fi; sleep 1; done
;;

esac
