# EKS Application Helm Chart

This Helm chart deploys a three-tier application consisting of:
- **Frontend**: React application with AWS LoadBalancer (2-5 replicas with HPA)
- **Backend**: Node.js API with ClusterIP service (3-10 replicas with HPA)
- **Database**: PostgreSQL with ClusterIP service and persistent storage

## Features

✅ **External Secrets Integration**: Credentials injected from AWS Secrets Manager  
✅ **PostgreSQL with Persistent Volumes**: Data persistence across pod restarts  
✅ **Horizontal Pod Autoscaling**: Frontend (2-5) and Backend (3-10) replicas  
✅ **Service Discovery**: Proper inter-service communication  
✅ **Health Probes**: Readiness and liveness probes for all services  
✅ **Security**: ServiceAccount with IRSA for AWS integration  

## Prerequisites

1. **EKS Cluster** with AWS Load Balancer Controller
2. **External Secrets Operator** (auto-installed by deploy script)
3. **AWS Secrets Manager** secrets created (run `../secretes.sh`)
4. **Helm 3.x** installed
5. **kubectl** configured for your EKS cluster

## Quick Start

```bash
# 1. Create secrets in AWS Secrets Manager
cd .. && ./secretes.sh

# 2. Update values.yaml with your specific configuration
# Edit helm-charts/eks-app/values.yaml:
# - Set serviceAccount.annotations.eks.amazonaws.com/role-arn

# 3. Deploy the application
cd helm-charts
chmod +x deploy.sh
./deploy.sh
```

## Configuration

### Key Values to Update

```yaml
# values.yaml
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::ACCOUNT:role/eks-external-secrets-role"
```

## Verification

### Check Pod Status
```bash
kubectl get pods -n eks-app
```

### Test Inter-Service Communication
```bash
# Test backend health
kubectl exec -it deployment/eks-app-backend -n eks-app -- curl http://localhost:3000/health

# Test database connection
kubectl exec -it deployment/eks-app-backend -n eks-app -- curl http://localhost:3000/version
```

### Verify Secrets
```bash
kubectl get secrets -n eks-app
kubectl describe externalsecret -n eks-app
```

### Check Autoscaling
```bash
kubectl get hpa -n eks-app
kubectl top pods -n eks-app
```

## Troubleshooting

### External Secrets Issues
```bash
# Check External Secrets Operator
kubectl logs -n external-secrets-system deployment/external-secrets

# Check SecretStore
kubectl describe secretstore aws-secrets-manager -n eks-app

# Check ExternalSecret status
kubectl describe externalsecret -n eks-app
```

### Database Connection Issues
```bash
# Check PostgreSQL logs
kubectl logs -f deployment/eks-app-postgresql -n eks-app

# Test database connectivity
kubectl exec -it deployment/eks-app-postgresql -n eks-app -- psql -U appuser -d appdb -c "SELECT 1;"
```

### Application Logs
```bash
# Frontend logs
kubectl logs -f deployment/eks-app-frontend -n eks-app

# Backend logs
kubectl logs -f deployment/eks-app-backend -n eks-app
```

## Cleanup

```bash
helm uninstall eks-app -n eks-app
kubectl delete namespace eks-app
```

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   PostgreSQL    │
│   (React)       │◄──►│   (Node.js)     │◄──►│   (Database)    │
│   Port: 80      │    │   Port: 3000    │    │   Port: 5432    │
│   Replicas: 2-5 │    │   Replicas: 3-10│    │   Persistent    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲                       ▲                       ▲
         │                       │                       │
    ┌────────────┐         ┌──────────┐         ┌──────────────┐
    │  Ingress   │         │   HPA    │         │    PVC       │
    │    ALB     │         │ CPU: 70% │         │   10Gi       │
    └────────────┘         └──────────┘         └──────────────┘
```

## Success Criteria Met

- ✅ All pods running in healthy state
- ✅ Inter-service communication functional  
- ✅ Database persistence across pod restarts
- ✅ Secrets properly mounted as environment variables