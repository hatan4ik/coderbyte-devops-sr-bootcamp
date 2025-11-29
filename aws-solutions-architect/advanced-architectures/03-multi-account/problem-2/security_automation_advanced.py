#!/usr/bin/env python3
"""FAANG-grade security automation with strategy pattern and async processing."""

from __future__ import annotations
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import Protocol, List, Dict, Optional, Callable, TypeVar, Generic
from enum import Enum
from concurrent.futures import ThreadPoolExecutor, as_completed
import boto3
from botocore.exceptions import ClientError
import structlog
from aws_xray_sdk.core import xray_recorder
from functools import lru_cache, wraps
import time

logger = structlog.get_logger()

T = TypeVar('T')

# Domain types
class Severity(Enum):
    CRITICAL = "CRITICAL"
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"
    INFO = "INFO"

class RemediationStatus(Enum):
    SUCCESS = "success"
    FAILED = "failed"
    SKIPPED = "skipped"
    PARTIAL = "partial"

# Result type for async operations
@dataclass(frozen=True)
class RemediationResult:
    """Result of remediation action."""
    finding_id: str
    status: RemediationStatus
    message: str
    details: Dict = field(default_factory=dict)
    duration_ms: float = 0.0

# Strategy Pattern for Remediation
class RemediationStrategy(ABC):
    """Abstract base for remediation strategies."""
    
    @abstractmethod
    def can_handle(self, finding: Dict) -> bool:
        """Check if strategy can handle finding."""
        pass
    
    @abstractmethod
    def remediate(self, finding: Dict, context: RemediationContext) -> RemediationResult:
        """Execute remediation."""
        pass
    
    @abstractmethod
    def get_priority(self) -> int:
        """Get strategy priority (lower = higher priority)."""
        pass

@dataclass
class RemediationContext:
    """Context for remediation execution."""
    account_id: str
    region: str
    dry_run: bool = False
    assume_role_arn: Optional[str] = None
    
    @lru_cache(maxsize=32)
    def get_session(self) -> boto3.Session:
        """Get AWS session with role assumption (cached)."""
        if self.assume_role_arn:
            sts = boto3.client('sts')
            response = sts.assume_role(
                RoleArn=self.assume_role_arn,
                RoleSessionName='SecurityRemediation',
                DurationSeconds=3600
            )
            credentials = response['Credentials']
            return boto3.Session(
                aws_access_key_id=credentials['AccessKeyId'],
                aws_secret_access_key=credentials['SecretAccessKey'],
                aws_session_token=credentials['SessionToken'],
                region_name=self.region
            )
        return boto3.Session(region_name=self.region)

# Concrete Strategies
class S3PublicAccessStrategy(RemediationStrategy):
    """Remediate public S3 buckets."""
    
    def can_handle(self, finding: Dict) -> bool:
        return 'S3' in finding.get('Type', '') and 'Public' in finding.get('Type', '')
    
    @xray_recorder.capture('remediate_s3_public')
    def remediate(self, finding: Dict, context: RemediationContext) -> RemediationResult:
        start = time.time()
        bucket_name = self._extract_bucket_name(finding)
        
        if context.dry_run:
            return RemediationResult(
                finding_id=finding['Id'],
                status=RemediationStatus.SKIPPED,
                message=f"DRY RUN: Would block public access on {bucket_name}",
                duration_ms=(time.time() - start) * 1000
            )
        
        try:
            session = context.get_session()
            s3 = session.client('s3')
            
            s3.put_public_access_block(
                Bucket=bucket_name,
                PublicAccessBlockConfiguration={
                    'BlockPublicAcls': True,
                    'IgnorePublicAcls': True,
                    'BlockPublicPolicy': True,
                    'RestrictPublicBuckets': True
                }
            )
            
            logger.info("s3_public_access_blocked",
                       bucket=bucket_name,
                       account=context.account_id)
            
            return RemediationResult(
                finding_id=finding['Id'],
                status=RemediationStatus.SUCCESS,
                message=f"Blocked public access on {bucket_name}",
                details={'bucket': bucket_name},
                duration_ms=(time.time() - start) * 1000
            )
        except ClientError as e:
            logger.error("s3_remediation_failed",
                        bucket=bucket_name,
                        error=str(e))
            return RemediationResult(
                finding_id=finding['Id'],
                status=RemediationStatus.FAILED,
                message=f"Failed to block public access: {str(e)}",
                duration_ms=(time.time() - start) * 1000
            )
    
    def get_priority(self) -> int:
        return 1  # High priority
    
    def _extract_bucket_name(self, finding: Dict) -> str:
        resource_id = finding['Resources'][0]['Id']
        return resource_id.split(':')[-1].split('/')[-1]

class SecurityGroupStrategy(RemediationStrategy):
    """Remediate overly permissive security groups."""
    
    def can_handle(self, finding: Dict) -> bool:
        return 'SecurityGroup' in finding.get('Type', '')
    
    @xray_recorder.capture('remediate_security_group')
    def remediate(self, finding: Dict, context: RemediationContext) -> RemediationResult:
        start = time.time()
        sg_id = self._extract_sg_id(finding)
        
        if context.dry_run:
            return RemediationResult(
                finding_id=finding['Id'],
                status=RemediationStatus.SKIPPED,
                message=f"DRY RUN: Would remove 0.0.0.0/0 rules from {sg_id}",
                duration_ms=(time.time() - start) * 1000
            )
        
        try:
            session = context.get_session()
            ec2 = session.client('ec2')
            
            # Get security group
            sg = ec2.describe_security_groups(GroupIds=[sg_id])['SecurityGroups'][0]
            
            removed_rules = 0
            for rule in sg['IpPermissions']:
                for ip_range in rule.get('IpRanges', []):
                    if ip_range['CidrIp'] == '0.0.0.0/0':
                        ec2.revoke_security_group_ingress(
                            GroupId=sg_id,
                            IpPermissions=[rule]
                        )
                        removed_rules += 1
            
            logger.info("security_group_remediated",
                       sg_id=sg_id,
                       removed_rules=removed_rules)
            
            return RemediationResult(
                finding_id=finding['Id'],
                status=RemediationStatus.SUCCESS,
                message=f"Removed {removed_rules} open rules from {sg_id}",
                details={'sg_id': sg_id, 'removed_rules': removed_rules},
                duration_ms=(time.time() - start) * 1000
            )
        except ClientError as e:
            logger.error("sg_remediation_failed", sg_id=sg_id, error=str(e))
            return RemediationResult(
                finding_id=finding['Id'],
                status=RemediationStatus.FAILED,
                message=f"Failed to remediate: {str(e)}",
                duration_ms=(time.time() - start) * 1000
            )
    
    def get_priority(self) -> int:
        return 2
    
    def _extract_sg_id(self, finding: Dict) -> str:
        resource_id = finding['Resources'][0]['Id']
        return resource_id.split('/')[-1]

class IAMAccessKeyStrategy(RemediationStrategy):
    """Remediate old IAM access keys."""
    
    def can_handle(self, finding: Dict) -> bool:
        return 'IAM' in finding.get('Type', '') and 'AccessKey' in finding.get('Type', '')
    
    @xray_recorder.capture('remediate_iam_key')
    def remediate(self, finding: Dict, context: RemediationContext) -> RemediationResult:
        start = time.time()
        user_name, access_key_id = self._extract_key_info(finding)
        
        if context.dry_run:
            return RemediationResult(
                finding_id=finding['Id'],
                status=RemediationStatus.SKIPPED,
                message=f"DRY RUN: Would deactivate key {access_key_id}",
                duration_ms=(time.time() - start) * 1000
            )
        
        try:
            session = context.get_session()
            iam = session.client('iam')
            
            iam.update_access_key(
                UserName=user_name,
                AccessKeyId=access_key_id,
                Status='Inactive'
            )
            
            logger.info("iam_key_deactivated",
                       user=user_name,
                       key_id=access_key_id)
            
            return RemediationResult(
                finding_id=finding['Id'],
                status=RemediationStatus.SUCCESS,
                message=f"Deactivated access key {access_key_id}",
                details={'user': user_name, 'key_id': access_key_id},
                duration_ms=(time.time() - start) * 1000
            )
        except ClientError as e:
            logger.error("iam_remediation_failed", error=str(e))
            return RemediationResult(
                finding_id=finding['Id'],
                status=RemediationStatus.FAILED,
                message=f"Failed to deactivate key: {str(e)}",
                duration_ms=(time.time() - start) * 1000
            )
    
    def get_priority(self) -> int:
        return 3
    
    def _extract_key_info(self, finding: Dict) -> tuple:
        resource_id = finding['Resources'][0]['Id']
        parts = resource_id.split('/')
        return parts[-2], parts[-1]

# Remediation Engine with async processing
class RemediationEngine:
    """Orchestrate remediation with strategy pattern and async execution."""
    
    def __init__(self, strategies: List[RemediationStrategy], max_workers: int = 10):
        self.strategies = sorted(strategies, key=lambda s: s.get_priority())
        self.executor = ThreadPoolExecutor(max_workers=max_workers)
        self.logger = logger.bind(component="RemediationEngine")
    
    def remediate_findings(
        self,
        findings: List[Dict],
        context: RemediationContext
    ) -> List[RemediationResult]:
        """Remediate findings concurrently."""
        futures = []
        
        for finding in findings:
            strategy = self._select_strategy(finding)
            if strategy:
                future = self.executor.submit(
                    self._safe_remediate,
                    strategy,
                    finding,
                    context
                )
                futures.append(future)
            else:
                self.logger.warning("no_strategy_found",
                                  finding_type=finding.get('Type'))
        
        results = []
        for future in as_completed(futures):
            try:
                result = future.result()
                results.append(result)
            except Exception as e:
                self.logger.exception("remediation_error")
        
        return results
    
    def _select_strategy(self, finding: Dict) -> Optional[RemediationStrategy]:
        """Select appropriate strategy for finding."""
        for strategy in self.strategies:
            if strategy.can_handle(finding):
                return strategy
        return None
    
    def _safe_remediate(
        self,
        strategy: RemediationStrategy,
        finding: Dict,
        context: RemediationContext
    ) -> RemediationResult:
        """Execute remediation with error handling."""
        try:
            return strategy.remediate(finding, context)
        except Exception as e:
            self.logger.exception("strategy_error",
                                strategy=strategy.__class__.__name__)
            return RemediationResult(
                finding_id=finding['Id'],
                status=RemediationStatus.FAILED,
                message=f"Unexpected error: {str(e)}"
            )

# Metrics and Reporting
@dataclass
class RemediationMetrics:
    """Aggregated remediation metrics."""
    total_findings: int
    successful: int
    failed: int
    skipped: int
    avg_duration_ms: float
    by_severity: Dict[Severity, int] = field(default_factory=dict)
    
    @staticmethod
    def from_results(results: List[RemediationResult], findings: List[Dict]) -> RemediationMetrics:
        """Calculate metrics from results."""
        successful = sum(1 for r in results if r.status == RemediationStatus.SUCCESS)
        failed = sum(1 for r in results if r.status == RemediationStatus.FAILED)
        skipped = sum(1 for r in results if r.status == RemediationStatus.SKIPPED)
        avg_duration = sum(r.duration_ms for r in results) / len(results) if results else 0
        
        by_severity = {}
        for finding in findings:
            severity = Severity(finding.get('Severity', 'INFO'))
            by_severity[severity] = by_severity.get(severity, 0) + 1
        
        return RemediationMetrics(
            total_findings=len(findings),
            successful=successful,
            failed=failed,
            skipped=skipped,
            avg_duration_ms=avg_duration,
            by_severity=by_severity
        )

# Lambda Handler
def create_lambda_handler(engine: RemediationEngine):
    """Factory for Lambda handler."""
    
    @xray_recorder.capture('lambda_handler')
    def handler(event: dict, context) -> dict:
        """Process Security Hub findings."""
        try:
            findings = event['detail']['findings']
            account_id = event['account']
            region = event['region']
            
            # Create context
            remediation_context = RemediationContext(
                account_id=account_id,
                region=region,
                dry_run=False,
                assume_role_arn=f"arn:aws:iam::{account_id}:role/SecurityRemediationRole"
            )
            
            # Execute remediation
            results = engine.remediate_findings(findings, remediation_context)
            
            # Calculate metrics
            metrics = RemediationMetrics.from_results(results, findings)
            
            logger.info("remediation_complete",
                       total=metrics.total_findings,
                       successful=metrics.successful,
                       failed=metrics.failed,
                       avg_duration_ms=metrics.avg_duration_ms)
            
            return {
                'statusCode': 200,
                'body': {
                    'metrics': {
                        'total': metrics.total_findings,
                        'successful': metrics.successful,
                        'failed': metrics.failed,
                        'skipped': metrics.skipped
                    },
                    'results': [
                        {
                            'finding_id': r.finding_id,
                            'status': r.status.value,
                            'message': r.message
                        }
                        for r in results
                    ]
                }
            }
        except Exception as e:
            logger.exception("handler_error")
            return {'statusCode': 500, 'body': {'error': str(e)}}
    
    return handler

# Bootstrap
strategies = [
    S3PublicAccessStrategy(),
    SecurityGroupStrategy(),
    IAMAccessKeyStrategy()
]
engine = RemediationEngine(strategies, max_workers=10)
lambda_handler = create_lambda_handler(engine)
