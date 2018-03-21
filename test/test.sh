#!/bin/sh

set -e

TRAEFIK_URL=http://traefik:80
TRAEFIK_API_URL=http://traefik:8080/api/providers/rest

echo "Configuring traefik via REST provider"
curl -sSf -X PUT $TRAEFIK_API_URL -d '
{
  "backends": {
    "backend": {
      "servers": {
        "backend": {
          "url": "http://backend:8000",
          "weight": 10
        }
      },
      "loadBalancer": {
        "method": "wrr"
      }
    }
  },
  "frontends": {
    "frontend1": {
      "entryPoints": ["http"],
      "backend": "backend",
      "routes": {
        "main": {
          "rule": "PathPrefixStrip:/prefix1"
        }
      },
      "passHostHeader": true,
      "headers": {
        "customRequestHeaders": {
          "X-Frontend": "1"
        }
      }
    },
    "frontend2": {
      "entryPoints": ["http"],
      "backend": "backend",
      "routes": {
        "main": {
          "rule": "PathPrefixStrip:/prefix2"
        }
      },
      "passHostHeader": true,
      "headers": {
        "customRequestHeaders": {
          "X-Frontend": "2"
        }
      }
    }
  }
}
' | jq '.'
echo

for i in $(seq 1 2); do
    url=http://traefik/prefix$i
    echo "Requesting $url"
    resp="$(curl -sSf $url)"
    echo "$resp"
    frontend=$(echo "$resp" | grep '^X-Frontend:' | cut -d' ' -f2 | tr -d '\n\r ')
    if [ "$frontend" -ne "$i" ]; then
        echo "Wrong frontend $frontend for $url" >&2
        exit 1
    fi
    echo
done
