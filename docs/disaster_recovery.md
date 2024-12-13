# Disaster Recovery Procedures

## Backup Strategy

### Automated Backups
1. RDS MySQL:
   - Daily automated backups (retention: 7 days)
   - Manual snapshots before major changes
   - Cross-region replication to DR region

2. ClickHouse:
   - Daily snapshots using AWS Backup
   - Retention: 7 days
   - Cross-region copy to DR region

3. S3:
   - Cross-region replication enabled
   - Versioning enabled
   - Lifecycle policies:
     - Move to IA after 30 days
     - Delete old versions after 90 days

### Monitoring Backups
- CloudWatch alarms for failed backups
- Daily backup report via SNS
- Weekly backup testing

## Disaster Recovery Procedures

### Scenario 1: Primary Region Failure

1. DNS Failover:
```bash
aws route53 update-health-check \
--health-check-id ${HEALTH_CHECK_ID} \
--regions eu-central-1
```


2. Promote DR Database:

```bash
aws rds promote-read-replica \
--db-instance-identifier prod-mysql-dr
```

3. Scale up DR EKS cluster:

```bash
kubectl scale deployment/api-deployment \
--replicas=4 -n production
```

### Scenario 2: Database Corruption

1. Point-in-Time Recovery:

```bash
aws rds restore-db-instance-to-point-in-time \
--source-db-instance-identifier prod-mysql \
--target-db-instance-identifier prod-mysql-restored \
--restore-time "2024-01-01T00:00:00Z"
```
### Scenario 3: Application Failure

1. Rollback Deployment:

```bash
kubectl rollout undo deployment/api-deployment \
-n production
```

## Recovery Time Objectives (RTO)
- Region Failure: < 30 minutes
- Database Recovery: < 1 hour
- Application Rollback: < 5 minutes

## Recovery Point Objectives (RPO)
- Database: < 5 minutes
- S3 Data: < 15 minutes
- Application State: < 1 minute

