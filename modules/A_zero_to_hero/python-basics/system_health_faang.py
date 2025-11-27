#!/usr/bin/env python3
"""FAANG-grade system health monitor with metrics, alerting, and observability."""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Protocol, List, Dict, Optional, Callable
from enum import Enum
from datetime import datetime
import psutil
import structlog
from prometheus_client import Gauge, Counter, generate_latest

logger = structlog.get_logger()

# Prometheus metrics
CPU_USAGE = Gauge('system_cpu_usage_percent', 'CPU usage percentage')
MEMORY_USAGE = Gauge('system_memory_usage_percent', 'Memory usage percentage')
DISK_USAGE = Gauge('system_disk_usage_percent', 'Disk usage percentage', ['mount_point'])
ALERTS_TRIGGERED = Counter('system_alerts_total', 'Total alerts triggered', ['alert_type'])

class AlertSeverity(Enum):
    """Alert severity levels."""
    INFO = "info"
    WARNING = "warning"
    CRITICAL = "critical"

@dataclass(frozen=True)
class Threshold:
    """Resource threshold configuration."""
    warning: float
    critical: float
    
    def check(self, value: float) -> Optional[AlertSeverity]:
        """Check value against thresholds."""
        if value >= self.critical:
            return AlertSeverity.CRITICAL
        elif value >= self.warning:
            return AlertSeverity.WARNING
        return None

@dataclass(frozen=True)
class ResourceMetric:
    """Immutable resource metric."""
    name: str
    value: float
    unit: str
    timestamp: datetime = field(default_factory=datetime.now)
    
    def to_dict(self) -> Dict:
        return {
            'name': self.name,
            'value': round(self.value, 2),
            'unit': self.unit,
            'timestamp': self.timestamp.isoformat()
        }

@dataclass(frozen=True)
class Alert:
    """System alert."""
    severity: AlertSeverity
    resource: str
    message: str
    value: float
    threshold: float
    timestamp: datetime = field(default_factory=datetime.now)
    
    def to_dict(self) -> Dict:
        return {
            'severity': self.severity.value,
            'resource': self.resource,
            'message': self.message,
            'value': round(self.value, 2),
            'threshold': self.threshold,
            'timestamp': self.timestamp.isoformat()
        }

class HealthCheck(Protocol):
    """Health check interface."""
    def check(self) -> ResourceMetric: ...
    def get_threshold(self) -> Threshold: ...

@dataclass
class CPUHealthCheck:
    """CPU usage health check."""
    interval: float = 1.0
    threshold: Threshold = field(default_factory=lambda: Threshold(warning=70.0, critical=90.0))
    
    def check(self) -> ResourceMetric:
        """Check CPU usage."""
        usage = psutil.cpu_percent(interval=self.interval)
        CPU_USAGE.set(usage)
        return ResourceMetric(name="cpu", value=usage, unit="percent")
    
    def get_threshold(self) -> Threshold:
        return self.threshold

@dataclass
class MemoryHealthCheck:
    """Memory usage health check."""
    threshold: Threshold = field(default_factory=lambda: Threshold(warning=75.0, critical=90.0))
    
    def check(self) -> ResourceMetric:
        """Check memory usage."""
        memory = psutil.virtual_memory()
        MEMORY_USAGE.set(memory.percent)
        return ResourceMetric(name="memory", value=memory.percent, unit="percent")
    
    def get_threshold(self) -> Threshold:
        return self.threshold

@dataclass
class DiskHealthCheck:
    """Disk usage health check."""
    mount_point: str = "/"
    threshold: Threshold = field(default_factory=lambda: Threshold(warning=80.0, critical=95.0))
    
    def check(self) -> ResourceMetric:
        """Check disk usage."""
        disk = psutil.disk_usage(self.mount_point)
        DISK_USAGE.labels(mount_point=self.mount_point).set(disk.percent)
        return ResourceMetric(name=f"disk_{self.mount_point}", value=disk.percent, unit="percent")
    
    def get_threshold(self) -> Threshold:
        return self.threshold

@dataclass
class HealthReport:
    """Aggregated health report."""
    metrics: List[ResourceMetric]
    alerts: List[Alert]
    timestamp: datetime = field(default_factory=datetime.now)
    
    @property
    def is_healthy(self) -> bool:
        """Check if system is healthy (no critical alerts)."""
        return not any(a.severity == AlertSeverity.CRITICAL for a in self.alerts)
    
    @property
    def has_warnings(self) -> bool:
        """Check if system has warnings."""
        return any(a.severity == AlertSeverity.WARNING for a in self.alerts)
    
    def to_dict(self) -> Dict:
        return {
            'timestamp': self.timestamp.isoformat(),
            'healthy': self.is_healthy,
            'has_warnings': self.has_warnings,
            'metrics': [m.to_dict() for m in self.metrics],
            'alerts': [a.to_dict() for a in self.alerts]
        }

class SystemHealthMonitor:
    """FAANG-grade system health monitor."""
    
    def __init__(self, checks: List[HealthCheck]):
        self.checks = checks
        self.logger = logger.bind(component="SystemHealthMonitor")
    
    def check_health(self) -> HealthReport:
        """Run all health checks and generate report."""
        metrics: List[ResourceMetric] = []
        alerts: List[Alert] = []
        
        for check in self.checks:
            try:
                metric = check.check()
                metrics.append(metric)
                
                # Check thresholds
                threshold = check.get_threshold()
                severity = threshold.check(metric.value)
                
                if severity:
                    alert = Alert(
                        severity=severity,
                        resource=metric.name,
                        message=f"{metric.name} usage is {severity.value}",
                        value=metric.value,
                        threshold=threshold.critical if severity == AlertSeverity.CRITICAL else threshold.warning
                    )
                    alerts.append(alert)
                    ALERTS_TRIGGERED.labels(alert_type=metric.name).inc()
                    
                    self.logger.warning("alert_triggered",
                                      resource=metric.name,
                                      severity=severity.value,
                                      value=metric.value)
            
            except Exception as e:
                self.logger.error("health_check_failed",
                                check=check.__class__.__name__,
                                error=str(e))
        
        report = HealthReport(metrics=metrics, alerts=alerts)
        
        self.logger.info("health_check_completed",
                        healthy=report.is_healthy,
                        alerts=len(alerts))
        
        return report

class HealthReporter:
    """Generate human-readable health reports."""
    
    @staticmethod
    def generate_report(report: HealthReport) -> str:
        """Generate formatted report."""
        lines = [
            "=== System Health Report ===",
            f"Timestamp: {report.timestamp.strftime('%Y-%m-%d %H:%M:%S')}",
            ""
        ]
        
        # Metrics
        lines.append("Metrics:")
        for metric in report.metrics:
            lines.append(f"  {metric.name.upper()}: {metric.value:.1f}{metric.unit}")
        lines.append("")
        
        # Alerts
        if report.alerts:
            lines.append("⚠️  Alerts:")
            for alert in sorted(report.alerts, key=lambda a: a.severity.value, reverse=True):
                icon = "🔴" if alert.severity == AlertSeverity.CRITICAL else "🟡"
                lines.append(f"  {icon} {alert.message} ({alert.value:.1f}% > {alert.threshold}%)")
        else:
            lines.append("✅ No alerts - System is healthy")
        
        return "\n".join(lines)

def main():
    """CLI entry point."""
    import sys
    import json
    
    output_json = "--json" in sys.argv
    output_metrics = "--metrics" in sys.argv
    
    # Initialize health checks
    checks: List[HealthCheck] = [
        CPUHealthCheck(),
        MemoryHealthCheck(),
        DiskHealthCheck()
    ]
    
    monitor = SystemHealthMonitor(checks)
    
    try:
        report = monitor.check_health()
        
        if output_metrics:
            # Output Prometheus metrics
            print(generate_latest().decode('utf-8'))
        elif output_json:
            # Output JSON
            print(json.dumps(report.to_dict(), indent=2))
        else:
            # Output human-readable report
            print(HealthReporter.generate_report(report))
        
        # Exit with appropriate code
        if not report.is_healthy:
            sys.exit(2)  # Critical
        elif report.has_warnings:
            sys.exit(1)  # Warning
        else:
            sys.exit(0)  # OK
    
    except Exception as e:
        logger.exception("monitoring_failed")
        sys.exit(3)

if __name__ == "__main__":
    main()
