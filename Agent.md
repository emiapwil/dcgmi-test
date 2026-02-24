# Healthchecks

This repository contains Dockerfiles for a set of health check tests.

## Structure

Each test resides in its own subdirectory. The naming convention is:

```
healthchecks/
├── <test-name>/
│   └── Dockerfile
└── Agent.md
```

## Available Tests

| Test | Description |
|------|-------------|
| `dcgm` | Build an image that can execute DCGM (Data Center GPU Manager) on a host. Based on Ubuntu 24.04 with DCGM, dcgm-exporter, dcgm-field-watch, and dcgm-devel packages. |

## Usage

Build a test image:

```bash
docker build -t <image-name> ./<test-name>/
```

Run the test:

```bash
docker run --rm <image-name>
```

## Adding a New Test

1. Create a new subdirectory with a descriptive name
2. Add a `Dockerfile` that defines the test environment
3. Update this `Agent.md` to document the new test
