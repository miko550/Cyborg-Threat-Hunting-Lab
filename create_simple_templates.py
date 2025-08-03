#!/usr/bin/env python3

import requests
import json

# Target Elasticsearch instance
TARGET_HOST = 'localhost:9200'
TARGET_AUTH = ('elastic', 'elastic@123')

# Simple templates that don't depend on Fleet components
SIMPLE_TEMPLATES = {
    'logs-windows.powershell': {
        "index_patterns": ["logs-windows.powershell-*"],
        "template": {
            "settings": {},
            "mappings": {
                "_meta": {
                    "package": {"name": "windows"},
                    "managed_by": "manual",
                    "managed": True
                }
            }
        },
        "priority": 200,
        "_meta": {
            "package": {"name": "windows"},
            "managed_by": "manual",
            "managed": True
        },
        "data_stream": {
            "hidden": False,
            "allow_custom_routing": False
        }
    },
    'logs-windows.powershell_operational': {
        "index_patterns": ["logs-windows.powershell_operational-*"],
        "template": {
            "settings": {},
            "mappings": {
                "_meta": {
                    "package": {"name": "windows"},
                    "managed_by": "manual",
                    "managed": True
                }
            }
        },
        "priority": 200,
        "_meta": {
            "package": {"name": "windows"},
            "managed_by": "manual",
            "managed": True
        },
        "data_stream": {
            "hidden": False,
            "allow_custom_routing": False
        }
    },
    'logs-windows.sysmon_operational': {
        "index_patterns": ["logs-windows.sysmon_operational-*"],
        "template": {
            "settings": {},
            "mappings": {
                "_meta": {
                    "package": {"name": "windows"},
                    "managed_by": "manual",
                    "managed": True
                }
            }
        },
        "priority": 200,
        "_meta": {
            "package": {"name": "windows"},
            "managed_by": "manual",
            "managed": True
        },
        "data_stream": {
            "hidden": False,
            "allow_custom_routing": False
        }
    },
    'logs-system.security': {
        "index_patterns": ["logs-system.security-*"],
        "template": {
            "settings": {},
            "mappings": {
                "_meta": {
                    "package": {"name": "system"},
                    "managed_by": "manual",
                    "managed": True
                }
            }
        },
        "priority": 200,
        "_meta": {
            "package": {"name": "system"},
            "managed_by": "manual",
            "managed": True
        },
        "data_stream": {
            "hidden": False,
            "allow_custom_routing": False
        }
    },
    'logs-system.application': {
        "index_patterns": ["logs-system.application-*"],
        "template": {
            "settings": {},
            "mappings": {
                "_meta": {
                    "package": {"name": "system"},
                    "managed_by": "manual",
                    "managed": True
                }
            }
        },
        "priority": 200,
        "_meta": {
            "package": {"name": "system"},
            "managed_by": "manual",
            "managed": True
        },
        "data_stream": {
            "hidden": False,
            "allow_custom_routing": False
        }
    }
}

def create_simple_templates():
    """Create simple templates that don't depend on Fleet components"""
    
    print(f"Creating simple templates on {TARGET_HOST}...")
    
    created_templates = []
    
    for template_name, template_config in SIMPLE_TEMPLATES.items():
        try:
            # Create template on target
            create_response = requests.put(
                f'http://{TARGET_HOST}/_index_template/{template_name}',
                auth=TARGET_AUTH,
                json=template_config,
                timeout=30
            )
            
            if create_response.status_code == 200:
                print(f"✓ Successfully created template: {template_name}")
                created_templates.append(template_name)
            else:
                print(f"✗ Failed to create template {template_name}: {create_response.status_code}")
                print(create_response.text)
                
        except Exception as e:
            print(f"✗ Error creating template {template_name}: {str(e)}")
    
    print(f"\n✓ Template creation completed!")
    print(f"✓ Created {len(created_templates)} templates: {', '.join(created_templates)}")
    
    if created_templates:
        print(f"\nNow you can run the ingest script and data should appear in Kibana Discover!")

if __name__ == "__main__":
    create_simple_templates() 