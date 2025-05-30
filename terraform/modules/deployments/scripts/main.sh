cat orderermsp.yaml | grep -A 100 "pem: |" | sed 's/.*pem: |//' | sed '/^[[:space:]]*$/d' | sed 's/^[[:space:]]*//' > /tmp/orderer-cert.pem

kubectl hlf channelcrd main create \
  --name demo \
  --channel-name demo \
  --admin-orderer-orgs OrdererMSP \
  --admin-peer-orgs Org1MSP \
  --orderer-orgs OrdererMSP \
  --peer-orgs Org1MSP \
  --absolute-max-bytes 1048576 \
  --max-message-count 10 \
  --preferred-max-bytes 524288 \
  --batch-timeout 2s \
  --etcd-raft-election-tick 10 \
  --etcd-raft-heartbeat-tick 1 \
  --etcd-raft-max-inflight-blocks 5 \
  --etcd-raft-snapshot-interval-size 16777216 \
  --etcd-raft-tick-interval 500ms \
  --identities "OrdererMSP;orderermsp.yaml" \
  --identities "OrdererMSP-sign;orderermspsign.yaml" \
  --identities "Org1MSP;org1msp.yaml" \
  --identities "Org1MSP-tls;org1msp-tlsca.yaml" \
  --secret-name wallet \
  --secret-ns default \
  --consenters "orderer0-ord.localho.st:443" \
  --consenter-certificates /tmp/orderer-cert.pem \
