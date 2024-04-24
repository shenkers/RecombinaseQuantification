# RecombinaseQuantification

# Docker Images

Change to the "docker" directory and run

```
NAMESPACE=something docker compose build
```

This will build the docker two docker containers:

- [NAMESPACE]-r : Used to knit the R-markdown report
- [NAMESPACE]-parasail : Used to perform sequence alignments

If you are running this workflow on the cloud or a compute cluster you will want to distribute these images to a container registry.
