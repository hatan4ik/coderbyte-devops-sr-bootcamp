#!/usr/bin/env python3
"""Automated cost optimization using Compute Optimizer and Cost Explorer."""

import boto3
from datetime import datetime, timedelta
from decimal import Decimal
from typing import Dict, List
import json

class CostOptimizer:
    """Automated AWS cost optimization system."""
    
    def __init__(self):
        self.compute_optimizer = boto3.client('compute-optimizer')
        self.ce = boto3.client('ce')
        self.ec2 = boto3.client('ec2')
        self.rds = boto3.client('rds')
        self.dynamodb = boto3.resource('dynamodb')
        self.sns = boto3.client('sns')
        self.tracking_table = self.dynamodb.Table('cost-optimization-tracking')
    
    def get_ec2_recommendations(self) -> List[Dict]:
        """Fetch EC2 rightsizing recommendations."""
        recommendations = []
        paginator = self.compute_optimizer.get_paginator('get_ec2_instance_recommendations')
        
        for page in paginator.paginate():
            for rec in page.get('instanceRecommendations', []):
                instance_arn = rec['instanceArn']
                instance_id = instance_arn.split('/')[-1]
                current_type = rec['currentInstanceType']
                
                # Get best recommendation
                options = rec.get('recommendationOptions', [])
                if not options:
                    continue
                
                best_option = options[0]
                recommended_type = best_option['instanceType']
                
                # Calculate savings
                current_cost = self._get_instance_cost(instance_id)
                projected_cost = best_option.get('projectedUtilizationMetrics', {})
                
                savings = current_cost - float(projected_cost.get('estimatedMonthlySavings', {}).get('value', 0))
                
                if savings > 0:
                    recommendations.append({
                        'resource_type': 'EC2',
                        'resource_id': instance_id,
                        'current_config': current_type,
                        'recommended_config': recommended_type,
                        'monthly_savings': round(savings, 2),
                        'finding_reason': rec.get('finding', 'Unknown'),
                        'risk_level': self._assess_risk(savings)
                    })
        
        return sorted(recommendations, key=lambda x: x['monthly_savings'], reverse=True)
    
    def get_rds_recommendations(self) -> List[Dict]:
        """Analyze RDS instances for optimization."""
        recommendations = []
        
        # Get all RDS instances
        response = self.rds.describe_db_instances()
        
        for db in response['DBInstances']:
            db_id = db['DBInstanceIdentifier']
            current_class = db['DBInstanceClass']
            
            # Get CloudWatch metrics
            metrics = self._get_rds_metrics(db_id)
            
            # Analyze utilization
            cpu_avg = metrics.get('cpu_avg', 0)
            memory_avg = metrics.get('memory_avg', 0)
            
            # Recommend downsize if underutilized
            if cpu_avg < 20 and memory_avg < 40:
                recommended_class = self._get_smaller_instance_class(current_class)
                if recommended_class:
                    current_cost = self._get_rds_cost(db_id)
                    projected_cost = current_cost * 0.5  # Estimate 50% savings
                    savings = current_cost - projected_cost
                    
                    recommendations.append({
                        'resource_type': 'RDS',
                        'resource_id': db_id,
                        'current_config': current_class,
                        'recommended_config': recommended_class,
                        'monthly_savings': round(savings, 2),
                        'finding_reason': f'Low utilization: CPU {cpu_avg}%, Memory {memory_avg}%',
                        'risk_level': 'medium'
                    })
            
            # Recommend Graviton2 if applicable
            if not current_class.endswith('g'):
                graviton_class = current_class.replace('db.', 'db.') + 'g'
                savings = current_cost * 0.2  # 20% savings with Graviton
                
                recommendations.append({
                    'resource_type': 'RDS',
                    'resource_id': db_id,
                    'current_config': current_class,
                    'recommended_config': graviton_class,
                    'monthly_savings': round(savings, 2),
                    'finding_reason': 'Graviton2 migration opportunity',
                    'risk_level': 'low'
                })
        
        return recommendations
    
    def get_lambda_recommendations(self) -> List[Dict]:
        """Analyze Lambda functions for memory optimization."""
        recommendations = []
        lambda_client = boto3.client('lambda')
        
        paginator = lambda_client.get_paginator('list_functions')
        
        for page in paginator.paginate():
            for func in page['Functions']:
                func_name = func['FunctionName']
                current_memory = func['MemorySize']
                
                # Get Compute Optimizer recommendations
                try:
                    rec = self.compute_optimizer.get_lambda_function_recommendations(
                        functionArns=[func['FunctionArn']]
                    )
                    
                    if rec.get('lambdaFunctionRecommendations'):
                        func_rec = rec['lambdaFunctionRecommendations'][0]
                        options = func_rec.get('memorySizeRecommendationOptions', [])
                        
                        if options:
                            best = options[0]
                            recommended_memory = best['memorySize']
                            savings = best.get('savingsOpportunity', {}).get('estimatedMonthlySavings', {}).get('value', 0)
                            
                            if savings > 0:
                                recommendations.append({
                                    'resource_type': 'Lambda',
                                    'resource_id': func_name,
                                    'current_config': f'{current_memory}MB',
                                    'recommended_config': f'{recommended_memory}MB',
                                    'monthly_savings': round(float(savings), 2),
                                    'finding_reason': 'Memory optimization',
                                    'risk_level': 'low'
                                })
                except Exception as e:
                    print(f"Error getting Lambda recommendations for {func_name}: {e}")
        
        return recommendations
    
    def process_recommendations(self, recommendations: List[Dict]):
        """Process recommendations with approval workflow."""
        for rec in recommendations:
            # Store in tracking table
            self._store_recommendation(rec)
            
            # Auto-approve low-risk, low-cost changes
            if rec['risk_level'] == 'low' and rec['monthly_savings'] < 100:
                self._execute_recommendation(rec)
            else:
                # Send for approval
                self._request_approval(rec)
    
    def _execute_recommendation(self, rec: Dict):
        """Execute approved recommendation."""
        resource_type = rec['resource_type']
        resource_id = rec['resource_id']
        new_config = rec['recommended_config']
        
        try:
            if resource_type == 'EC2':
                # Stop instance, modify type, start
                self.ec2.stop_instances(InstanceIds=[resource_id])
                waiter = self.ec2.get_waiter('instance_stopped')
                waiter.wait(InstanceIds=[resource_id])
                
                self.ec2.modify_instance_attribute(
                    InstanceId=resource_id,
                    InstanceType={'Value': new_config}
                )
                
                self.ec2.start_instances(InstanceIds=[resource_id])
                
            elif resource_type == 'RDS':
                self.rds.modify_db_instance(
                    DBInstanceIdentifier=resource_id,
                    DBInstanceClass=new_config,
                    ApplyImmediately=False  # Apply during maintenance window
                )
            
            elif resource_type == 'Lambda':
                memory_mb = int(new_config.replace('MB', ''))
                lambda_client = boto3.client('lambda')
                lambda_client.update_function_configuration(
                    FunctionName=resource_id,
                    MemorySize=memory_mb
                )
            
            # Update tracking
            self._update_tracking(rec, 'executed')
            
        except Exception as e:
            print(f"Error executing recommendation: {e}")
            self._update_tracking(rec, 'failed', str(e))
    
    def _request_approval(self, rec: Dict):
        """Send recommendation for approval via SNS."""
        message = f"""
Cost Optimization Recommendation Requires Approval

Resource Type: {rec['resource_type']}
Resource ID: {rec['resource_id']}
Current Config: {rec['current_config']}
Recommended Config: {rec['recommended_config']}
Monthly Savings: ${rec['monthly_savings']}
Risk Level: {rec['risk_level']}
Reason: {rec['finding_reason']}

To approve, reply with: APPROVE {rec['resource_id']}
To reject, reply with: REJECT {rec['resource_id']}
        """
        
        self.sns.publish(
            TopicArn='arn:aws:sns:us-east-1:123456789012:cost-optimization-approvals',
            Subject='Cost Optimization Approval Required',
            Message=message
        )
        
        self._update_tracking(rec, 'pending_approval')
    
    def _store_recommendation(self, rec: Dict):
        """Store recommendation in DynamoDB."""
        self.tracking_table.put_item(
            Item={
                'recommendation_id': f"{rec['resource_type']}-{rec['resource_id']}-{datetime.now().isoformat()}",
                'resource_type': rec['resource_type'],
                'resource_id': rec['resource_id'],
                'current_config': rec['current_config'],
                'recommended_config': rec['recommended_config'],
                'monthly_savings': Decimal(str(rec['monthly_savings'])),
                'risk_level': rec['risk_level'],
                'finding_reason': rec['finding_reason'],
                'status': 'identified',
                'created_at': datetime.now().isoformat()
            }
        )
    
    def _update_tracking(self, rec: Dict, status: str, error: str = None):
        """Update recommendation status."""
        update_expr = 'SET #status = :status, updated_at = :updated'
        expr_values = {
            ':status': status,
            ':updated': datetime.now().isoformat()
        }
        
        if error:
            update_expr += ', error_message = :error'
            expr_values[':error'] = error
        
        self.tracking_table.update_item(
            Key={'recommendation_id': f"{rec['resource_type']}-{rec['resource_id']}"},
            UpdateExpression=update_expr,
            ExpressionAttributeNames={'#status': 'status'},
            ExpressionAttributeValues=expr_values
        )
    
    def _assess_risk(self, savings: float) -> str:
        """Assess risk level based on savings amount."""
        if savings < 100:
            return 'low'
        elif savings < 500:
            return 'medium'
        else:
            return 'high'
    
    def _get_instance_cost(self, instance_id: str) -> float:
        """Get monthly cost for EC2 instance."""
        end = datetime.now()
        start = end - timedelta(days=30)
        
        response = self.ce.get_cost_and_usage(
            TimePeriod={
                'Start': start.strftime('%Y-%m-%d'),
                'End': end.strftime('%Y-%m-%d')
            },
            Granularity='MONTHLY',
            Metrics=['UnblendedCost'],
            Filter={
                'Dimensions': {
                    'Key': 'RESOURCE_ID',
                    'Values': [instance_id]
                }
            }
        )
        
        if response['ResultsByTime']:
            return float(response['ResultsByTime'][0]['Total']['UnblendedCost']['Amount'])
        return 0.0
    
    def _get_rds_cost(self, db_id: str) -> float:
        """Get monthly cost for RDS instance."""
        # Similar to _get_instance_cost but for RDS
        return 500.0  # Placeholder
    
    def _get_rds_metrics(self, db_id: str) -> Dict:
        """Get CloudWatch metrics for RDS."""
        cloudwatch = boto3.client('cloudwatch')
        end = datetime.now()
        start = end - timedelta(days=7)
        
        cpu_response = cloudwatch.get_metric_statistics(
            Namespace='AWS/RDS',
            MetricName='CPUUtilization',
            Dimensions=[{'Name': 'DBInstanceIdentifier', 'Value': db_id}],
            StartTime=start,
            EndTime=end,
            Period=3600,
            Statistics=['Average']
        )
        
        cpu_avg = sum(dp['Average'] for dp in cpu_response['Datapoints']) / len(cpu_response['Datapoints']) if cpu_response['Datapoints'] else 0
        
        return {
            'cpu_avg': round(cpu_avg, 2),
            'memory_avg': 50.0  # Placeholder
        }
    
    def _get_smaller_instance_class(self, current: str) -> str:
        """Get next smaller instance class."""
        size_map = {
            'db.r5.2xlarge': 'db.r5.xlarge',
            'db.r5.xlarge': 'db.r5.large',
            'db.r5.large': 'db.r5.medium'
        }
        return size_map.get(current)
    
    def generate_monthly_report(self) -> Dict:
        """Generate monthly cost optimization report."""
        # Query tracking table for last 30 days
        end = datetime.now()
        start = end - timedelta(days=30)
        
        response = self.tracking_table.scan(
            FilterExpression='created_at BETWEEN :start AND :end',
            ExpressionAttributeValues={
                ':start': start.isoformat(),
                ':end': end.isoformat()
            }
        )
        
        items = response['Items']
        
        total_identified = sum(float(item['monthly_savings']) for item in items)
        executed = [item for item in items if item['status'] == 'executed']
        total_realized = sum(float(item['monthly_savings']) for item in executed)
        
        return {
            'period': f"{start.date()} to {end.date()}",
            'recommendations_identified': len(items),
            'recommendations_executed': len(executed),
            'potential_savings': round(total_identified, 2),
            'realized_savings': round(total_realized, 2),
            'by_resource_type': self._group_by_type(items),
            'by_risk_level': self._group_by_risk(items)
        }
    
    def _group_by_type(self, items: List[Dict]) -> Dict:
        """Group recommendations by resource type."""
        grouped = {}
        for item in items:
            rtype = item['resource_type']
            if rtype not in grouped:
                grouped[rtype] = {'count': 0, 'savings': 0}
            grouped[rtype]['count'] += 1
            grouped[rtype]['savings'] += float(item['monthly_savings'])
        return grouped
    
    def _group_by_risk(self, items: List[Dict]) -> Dict:
        """Group recommendations by risk level."""
        grouped = {}
        for item in items:
            risk = item['risk_level']
            if risk not in grouped:
                grouped[risk] = {'count': 0, 'savings': 0}
            grouped[risk]['count'] += 1
            grouped[risk]['savings'] += float(item['monthly_savings'])
        return grouped

# Lambda handler
def lambda_handler(event, context):
    """Main Lambda handler for cost optimization."""
    optimizer = CostOptimizer()
    
    # Get all recommendations
    ec2_recs = optimizer.get_ec2_recommendations()
    rds_recs = optimizer.get_rds_recommendations()
    lambda_recs = optimizer.get_lambda_recommendations()
    
    all_recs = ec2_recs + rds_recs + lambda_recs
    
    # Process recommendations
    optimizer.process_recommendations(all_recs)
    
    # Generate report
    report = optimizer.generate_monthly_report()
    
    return {
        'statusCode': 200,
        'body': json.dumps(report)
    }

if __name__ == '__main__':
    optimizer = CostOptimizer()
    
    print("Fetching EC2 recommendations...")
    ec2_recs = optimizer.get_ec2_recommendations()
    print(f"Found {len(ec2_recs)} EC2 optimization opportunities")
    
    print("\nFetching RDS recommendations...")
    rds_recs = optimizer.get_rds_recommendations()
    print(f"Found {len(rds_recs)} RDS optimization opportunities")
    
    print("\nFetching Lambda recommendations...")
    lambda_recs = optimizer.get_lambda_recommendations()
    print(f"Found {len(lambda_recs)} Lambda optimization opportunities")
    
    total_savings = sum(r['monthly_savings'] for r in ec2_recs + rds_recs + lambda_recs)
    print(f"\nTotal potential monthly savings: ${total_savings:,.2f}")
