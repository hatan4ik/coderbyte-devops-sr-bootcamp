#!/usr/bin/env python3
"""Config Parser - Parse INI configuration files"""

import configparser
import sys
import os

def parse_config(filename):
    if not filename:
        print("Usage: python config_parser_ini_12.py <config_file>")
        return
    
    if not os.path.exists(filename):
        print(f"Error: Config file '{filename}' not found")
        return
    
    config = configparser.ConfigParser()
    
    try:
        config.read(filename)
    except Exception as e:
        print(f"Error parsing config file: {e}")
        return
    
    print(f"Configuration file: {filename}")
    print(f"Sections found: {list(config.sections())}")
    
    for section_name in config.sections():
        print(f"\n[{section_name}]")
        for key, value in config[section_name].items():
            print(f"  {key} = {value}")
    
    # Example of accessing specific values
    if 'database' in config:
        db_config = config['database']
        print(f"\nDatabase configuration:")
        print(f"  Host: {db_config.get('host', 'localhost')}")
        print(f"  Port: {db_config.get('port', '5432')}")
        print(f"  Database: {db_config.get('name', 'default')}")

def create_sample_config():
    """Create a sample config file for testing"""
    config = configparser.ConfigParser()
    
    config['database'] = {
        'host': 'localhost',
        'port': '5432',
        'name': 'myapp',
        'user': 'admin'
    }
    
    config['logging'] = {
        'level': 'INFO',
        'file': '/var/log/app.log',
        'max_size': '10MB'
    }
    
    config['api'] = {
        'base_url': 'https://api.example.com',
        'timeout': '30',
        'retries': '3'
    }
    
    with open('sample_config.ini', 'w') as f:
        config.write(f)
    
    print("Sample config file created: sample_config.ini")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        parse_config(sys.argv[1])
    else:
        create_sample_config()
        parse_config('sample_config.ini')