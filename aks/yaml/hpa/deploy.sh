# Deploy app
kubectl apply -f https://k8s.io/examples/application/php-apache.yaml

# Create HPA
kubectl autoscale deployment php-apache --cpu-percent=30 --min=1 --max=5

kubectl get hpa