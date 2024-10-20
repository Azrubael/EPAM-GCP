### 2024-10-17  11:19
---------------------

The project of Pet Clinic with to instances in Docker.
Created via `docker compose up -d`.

The workflow is described in detail in `WORKFLOW.md`.
In short, the order is as follows:
- launch a VM based on Ubuntu 20.04, install Terreform and Docker;
- run `1-pulling-images.sh` to download the necessary images;
- run `docker compose up -d`;
- check the operation of the application `curl localhost:8080`;
- upload the finished image to DockerHub using `2-pushing-petlab.sh`;
- optionally, run `docker compose -f pet-lab.yml up -d`.