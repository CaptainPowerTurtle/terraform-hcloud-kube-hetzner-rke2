---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: cilium
  namespace: kube-system
spec:
  chart: cilium
  repo: https://helm.cilium.io/
  version: "${version}"
  targetNamespace: kube-system
  bootstrap: true
  valuesContent: |-
    ${values}
---
apiVersion: "cilium.io/v2alpha1"
kind: CiliumLoadBalancerIPPool
metadata:
  name: "pool"
spec:
  blocks:
    - cidr: ${ipv4_address}