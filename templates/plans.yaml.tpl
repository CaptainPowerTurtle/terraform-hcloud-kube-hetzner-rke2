---
# Doc: https://rancher.com/docs/rke2/latest/en/upgrades/automated/
# agent plan
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: rke2-agent
  namespace: system-upgrade
  labels:
    rke2_upgrade: agent
spec:
  concurrency: 1
  %{~ if version == "" ~}
  channel: https://update.rke2.io/v1-release/channels/${channel}
  %{~ else ~}
  version: ${version}
  %{~ endif ~}
  serviceAccountName: system-upgrade
  nodeSelector:
    matchExpressions:
      - {key: rke2_upgrade, operator: Exists}
      - {key: rke2_upgrade, operator: NotIn, values: ["disabled", "false"]}
      - {key: node-role.kubernetes.io/control-plane, operator: NotIn, values: ["true"]}
      - {key: kured, operator: NotIn, values: ["rebooting"]}
  tolerations:
    - {key: server-usage, effect: NoSchedule, operator: Equal, value: storage}
    - {operator: Exists}
  prepare:
    image: rancher/rke2-upgrade
    args: ["prepare", "rke2-server"]
  %{ if drain }drain:
    force: true
    disableEviction: ${disable_eviction}
    skipWaitForDeleteTimeout: 60%{ endif }
  %{ if !drain }cordon: true%{ endif }
  upgrade:
    image: rancher/rke2-upgrade
---
# server plan
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: rke2-server
  namespace: system-upgrade
  labels:
    rke2_upgrade: server
spec:
  concurrency: 1
  %{~ if version == "" ~}
  channel: https://update.rke2.io/v1-release/channels/${channel}
  %{~ else ~}
  version: ${version}
  %{~ endif ~}
  serviceAccountName: system-upgrade
  nodeSelector:
    matchExpressions:
      - {key: rke2_upgrade, operator: Exists}
      - {key: rke2_upgrade, operator: NotIn, values: ["disabled", "false"]}
      - {key: node-role.kubernetes.io/control-plane, operator: In, values: ["true"]}
      - {key: kured, operator: NotIn, values: ["rebooting"]}
  tolerations:
    - {key: node-role.kubernetes.io/control-plane, effect: NoSchedule, operator: Exists}
    - {key: CriticalAddonsOnly, effect: NoExecute, operator: Exists}
  cordon: true
  upgrade:
    image: rancher/rke2-upgrade
