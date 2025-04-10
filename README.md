# gpodder/mygpo Docker Image Builder

This repository automatically builds and releases Docker images for the [gpodder/mygpo](https://github.com/gpodder/mygpo) project.

## How it Works

A GitHub Actions workflow runs daily (and on pushes to `main`) to:
1.  Check for new commits in the `gpodder/mygpo` repository.
2.  If new commits are found, build a new Docker image.
3.  Push the image to GitHub Container Registry (GHCR) at `ghcr.io/thekoma/gpodder-docker`. Images are tagged with `latest` and the Git SHA of the build commit in this repository.
4.  Create a new GitHub Release in this repository. The release tag follows the format `YYYY.MM.N` (e.g., `2025.04.0`) and includes a changelog generated from the new `gpodder/mygpo` commit messages.
5.  Tag the corresponding Docker image on GHCR with the new release tag (e.g., `ghcr.io/thekoma/gpodder-docker:2025.04.0`).
6.  Update the `last_source_commit.txt` file to track the latest processed commit from `gpodder/mygpo`.

## Using the Docker Image with Docker Compose

A `docker-compose.yml` file is provided for easy deployment using PostgreSQL as the database backend.

**1. Create an Environment File:**

Copy the example environment file:
```bash
cp .env.example .env
```
Now, edit the `.env` file and set the required values:

*   `POSTGRES_DB`: Name for the mygpo database (e.g., `mygpo`).
*   `POSTGRES_USER`: Username for the database user (e.g., `mygpo`).
*   `POSTGRES_PASSWORD`: **A strong, unique password** for the database user.
*   `MYGPO_SECRET_KEY`: **A long, random, and secret string.** You MUST change this for security. You can generate one using `openssl rand -base64 32` or similar tools.
*   `MYGPO_ALLOWED_HOSTS`: Comma-separated list of hostnames/IP addresses allowed to serve the site (e.g., `localhost,127.0.0.1,yourdomain.com`).
*   `MYGPO_DEFAULT_BASE_URL`: The base URL of your deployment (e.g., `https://gpodder.yourdomain.com`). This is crucial for generating correct URLs within the application.

**2. Start the Services:**

```bash
docker-compose up -d
```
This will download the images (if not present locally) and start the `mygpo` application container (`app`) and the PostgreSQL database container (`db`).

**3. Initialize the Database:**

After the containers are running for the first time, you need to run the database migrations:
```bash
docker-compose exec app python manage.py migrate
```

**4. Access mygpo:**

Your mygpo instance should now be accessible at the host and port configured (default is port 8000 on your Docker host, e.g., `http://localhost:8000`).

## Configuration Variables

The `mygpo` application is configured via environment variables. The essential variables needed for the `docker-compose` setup are defined in the `.env` file (see above).

Refer to the [official mygpo configuration documentation](https://gpoddernet.readthedocs.io/en/latest/dev/reference/settings.html) for a complete list of available variables if you need further customization. These can be added to the `environment` section of the `app` service in `docker-compose.yml` or directly to your `.env` file (if the compose file is adapted to read them).

## Docker Image Registry

Images are available on GitHub Container Registry:
[ghcr.io/thekoma/gpodder-docker](https://github.com/thekoma/gpodder-docker/pkgs/container/gpodder-docker)

You can pull a specific release tag (e.g., `2025.04.0`) or `latest`.
```bash
docker pull ghcr.io/thekoma/gpodder-docker:latest
```
