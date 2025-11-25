#!/usr/bin/env python3
"""Docker SDK Automation - Manage Docker containers with Python"""

import sys

def list_containers():
    """List all containers"""
    try:
        import docker
        client = docker.from_env()
        
        containers = client.containers.list(all=True)
        print(f"Found {len(containers)} containers:")
        
        for container in containers:
            status = container.status
            name = container.name
            image = container.image.tags[0] if container.image.tags else container.image.id[:12]
            print(f"  {name}: {image} ({status})")
            
    except ImportError:
        print("Docker SDK not available. Install with: pip install docker")
    except Exception as e:
        print(f"Error connecting to Docker: {e}")

def container_stats(container_name):
    """Get container statistics"""
    try:
        import docker
        client = docker.from_env()
        
        container = client.containers.get(container_name)
        stats = container.stats(stream=False)
        
        # Calculate CPU percentage
        cpu_delta = stats['cpu_stats']['cpu_usage']['total_usage'] - stats['precpu_stats']['cpu_usage']['total_usage']
        system_delta = stats['cpu_stats']['system_cpu_usage'] - stats['precpu_stats']['system_cpu_usage']
        cpu_percent = (cpu_delta / system_delta) * 100.0 if system_delta > 0 else 0
        
        # Memory usage
        memory_usage = stats['memory_stats']['usage']
        memory_limit = stats['memory_stats']['limit']
        memory_percent = (memory_usage / memory_limit) * 100.0
        
        print(f"Container: {container_name}")
        print(f"CPU Usage: {cpu_percent:.2f}%")
        print(f"Memory Usage: {memory_usage / (1024**2):.1f}MB / {memory_limit / (1024**2):.1f}MB ({memory_percent:.1f}%)")
        
    except ImportError:
        print("Docker SDK not available. Install with: pip install docker")
    except Exception as e:
        print(f"Error getting container stats: {e}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python docker_sdk_automation_11.py <command> [args]")
        print("Commands:")
        print("  list - List all containers")
        print("  stats <container_name> - Show container statistics")
        return
    
    command = sys.argv[1]
    
    if command == "list":
        list_containers()
    elif command == "stats" and len(sys.argv) > 2:
        container_stats(sys.argv[2])
    else:
        print("Invalid command or missing arguments")

if __name__ == "__main__":
    main()