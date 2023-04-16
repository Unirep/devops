kubectl -n cattle-system patch deployments cattle-cluster-agent --patch '{"spec": {"template": {"spec": {"dnsPolicy": "None","dnsConfig": {"nameservers": ["8.8.8.8"]}}}}}'
