# Duplicati Backup Service

This repository contains a Docker Compose setup for running [Duplicati](https://www.duplicati.com/), an open-source backup client that securely stores encrypted backups on cloud storage services and remote file servers.

## Overview

Duplicati is configured to:
- Run as a Docker container using the LinuxServer.io image
- Store configuration in `./config`
- Store backup files in `./backups`
- Backup files from `/Users/gustavosilva/workspace` (mounted as `/source` in the container)
- Access the web interface on port `8200`

## Prerequisites

- Docker and Docker Compose installed
- Make (for using the Makefile commands)

## Quick Start

### 1. Build the Service

```bash
make build
```

This builds the Duplicati Docker container.

### 2. Run the Service

```bash
make run
```

This starts the Duplicati service in detached mode (runs in the background).

### 3. Access the Web Interface

Once the service is running, open your web browser and navigate to:

```
http://localhost:8200
```

**Login Credentials:**
- **Password:** `password` (as configured in `docker-compose.yml`)

> **Note:** The password is set via the `DUPLICATI__WEBSERVICE_PASSWORD` environment variable. Change it in `docker-compose.yml` for production use.

## Creating Your First Backup

### Step 1: Add a Backup Configuration

1. In the Duplicati web interface, click **"Add backup"** or **"New backup"**
2. Give your backup a descriptive name (e.g., "Workspace Backup")

### Step 2: Configure Backup Destination

Choose where you want to store your backups. Duplicati supports many destinations:

- **Cloud Storage:** AWS S3, Google Drive, Dropbox, OneDrive, Backblaze B2, etc.
- **FTP/SFTP:** Remote servers
- **Local/Network:** Local folders or network shares
- **And many more...**

**Example - Local Backup:**
- Select **"Local folder or drive"**
- Path: `/backups/my-backup` (this maps to `./backups/my-backup` on your host)

**Example - AWS S3:**
- Select **"S3 Compatible"** or **"Amazon S3"**
- Enter your S3 credentials and bucket name

### Step 3: Select Files to Backup

1. Click **"Next"** or **"Source data"**
2. Click **"Add folder"** or **"Add file"**
3. Navigate to `/source` (which maps to `/Users/gustavosilva/workspace` on your host)
4. Select the folders or files you want to backup
5. You can add multiple sources

### Step 4: Configure Schedule (Optional)

1. Set up a backup schedule:
   - **Daily:** Run at a specific time each day
   - **Weekly:** Run on specific days
   - **Monthly:** Run on specific dates
   - **Manual:** Only run when you click "Run now"

### Step 5: Set Encryption Password

1. Enter a strong encryption password
2. **Important:** Save this password securely! You'll need it to restore backups.
3. Duplicati will encrypt your backups using this password

### Step 6: Review and Save

1. Review your backup configuration
2. Click **"Save"** or **"Create"**
3. Your backup is now configured!

### Step 7: Run Your First Backup

1. Find your backup in the list
2. Click **"Run now"** or wait for the scheduled time
3. Monitor the progress in the web interface

## Managing Backups

### Viewing Backup Status

- The main dashboard shows all configured backups
- Green indicators mean backups are running successfully
- Red indicators mean there are errors (check the logs)

### Running Manual Backups

1. Click on a backup configuration
2. Click **"Run now"** to start an immediate backup

### Viewing Backup Logs

1. Click on a backup configuration
2. Navigate to the **"Log"** or **"Reports"** tab
3. View detailed information about backup runs

### Restoring Files

1. Click on a backup configuration
2. Click **"Restore"** or **"Restore files"**
3. Select the backup version you want to restore from
4. Choose the files/folders to restore
5. Select the destination for restored files
6. Enter your encryption password
7. Click **"Restore"**

## Backing Up and Restoring Across Different Computers

Yes, you can absolutely backup data on one computer and restore it on another! This is one of Duplicati's key features. Here's how:

### Scenario: Backup on Computer A, Restore on Computer B

#### On Computer A (Source Computer):

1. **Create Your Backup:**
   - Set up a backup configuration as described in "Creating Your First Backup"
   - Choose a destination (local folder, cloud storage, etc.)
   - Run your backup

2. **Export Backup Files:**
   - If backing up to local folder (`/backups`), the backup files will be in `./backups/` on your host
   - Copy the entire backup folder to an external drive, USB stick, or cloud storage
   - **Important:** Copy ALL files in the backup folder (`.dlist.zip.aes`, `.dblock.zip.aes`, etc.)

#### On Computer B (Destination Computer):

**Option 1: Using the Restore Folder (Easiest)**

1. **Set up Duplicati on Computer B:**
   - Clone or copy this repository to Computer B
   - Run `make build` and `make run`
   - Access the web interface at `http://localhost:8200`

2. **Copy Backup Files to Restore Folder:**
   - Copy all backup files from Computer A to the `./restore` folder on Computer B
   - The files will be accessible at `/restore` inside the container

3. **Restore Using Direct Restore:**
   - In the Duplicati web interface, click **"Restore"** (from the main menu, not from a backup config)
   - Select **"Direct restore from backup files"** or **"Restore from files"**
   - Choose **"Local folder or drive"**
   - Path: `/restore` (or the specific subfolder where you placed the backup files)
   - Enter your **encryption password** (the one you set when creating the backup)
   - Duplicati will scan and display available backups
   - Select the backup version you want to restore
   - Choose files/folders to restore
   - Select destination (e.g., `/source` or any other location)
   - Click **"Restore"**

**Option 2: Using Cloud Storage or Network Share**

1. **If you backed up to cloud storage (S3, Google Drive, etc.):**
   - On Computer B, set up Duplicati
   - Click **"Restore"** → **"Direct restore from backup files"**
   - Select the same cloud storage type
   - Enter the same credentials
   - Navigate to the backup location
   - Enter your encryption password
   - Select and restore files

2. **If you backed up to a network share:**
   - Mount the network share on Computer B
   - Use **"Direct restore from backup files"** and point to the network location

### Important Notes for Cross-Computer Restore:

✅ **What You Need:**
- The backup files (all `.dlist.zip.aes`, `.dblock.zip.aes`, and other files)
- Your **encryption password** (the one you set when creating the backup)
- Duplicati installed/running on the destination computer

❌ **What You DON'T Need:**
- The original backup configuration (you can restore without it)
- The original source files
- The Duplicati configuration database from Computer A

### Restore Folder Usage

The `./restore` folder is mounted at `/restore` in the container. This is a convenient place to:
- Drop backup files you've copied from another computer
- Store backup files you want to restore later
- Organize multiple backup sets for restoration

**Example Workflow:**
```bash
# On Computer B, after copying backup files
./restore/
  └── my-backup/
      ├── duplicati-20251214T014341Z.dlist.zip.aes
      ├── duplicati-20251214T014341Z.dblock.zip.aes
      └── ... (other backup files)
```

Then in Duplicati, use path `/restore/my-backup` for direct restore.

## Configuration Details

### Environment Variables

- `PUID=0` / `PGID=0`: User/Group IDs (root user)
- `TZ=America/New_York`: Timezone for scheduling
- `SETTINGS_ENCRYPTION_KEY`: Key for encrypting Duplicati settings
- `DUPLICATI__WEBSERVICE_PASSWORD`: Password for web interface access

### Volume Mounts

- `./config:/config`: Duplicati configuration and database
- `./backups:/backups`: Local backup storage location
- `./restore:/restore`: Restore folder - place backup files here to restore on another computer
- `/Users/gustavosilva/workspace:/source`: Source files to backup

### Ports

- `8200:8200`: Web interface port

## Useful Commands

### View Logs

```bash
docker compose logs -f duplicati
```

### Stop the Service

```bash
docker compose down
```

### Restart the Service

```bash
docker compose restart duplicati
```

### View Running Containers

```bash
docker compose ps
```

## Best Practices

1. **Test Your Backups:** Periodically restore a file to ensure backups are working
2. **Multiple Destinations:** Consider backing up to multiple locations (e.g., local + cloud)
3. **Encryption Password:** Use a strong, unique password and store it securely
4. **Regular Schedules:** Set up automatic backups rather than relying on manual runs
5. **Monitor Logs:** Check backup logs regularly to catch issues early
6. **Version Retention:** Configure how many backup versions to keep to manage storage
7. **Exclude Files:** Exclude temporary files, caches, and other unnecessary data

## Troubleshooting

### Can't Access Web Interface

- Check if the container is running: `docker compose ps`
- Check if port 8200 is already in use: `lsof -i :8200`
- View container logs: `docker compose logs duplicati`

### Backup Fails

- Check the backup logs in the web interface
- Verify destination credentials are correct
- Ensure there's enough disk space
- Check network connectivity for cloud destinations

### Permission Issues

- If you have permission errors, you may need to adjust `PUID` and `PGID` in `docker-compose.yml`
- Check file permissions on mounted volumes

## Additional Resources

- [Duplicati Official Documentation](https://www.duplicati.com/support/documentation)
- [Duplicati User Guide](https://duplicati.readthedocs.io/)
- [LinuxServer.io Duplicati Image](https://hub.docker.com/r/linuxserver/duplicati)

## Security Notes

⚠️ **Important Security Considerations:**

1. **Change Default Password:** The default web interface password is `password`. Change it in `docker-compose.yml` before deploying to production.
2. **Encryption Key:** The `SETTINGS_ENCRYPTION_KEY` should be changed to a secure random value.
3. **Backup Encryption:** Always use strong encryption passwords for your backups.
4. **Credentials:** Store cloud storage credentials securely. Consider using Docker secrets or environment files.

## License

This setup uses Duplicati, which is licensed under LGPL.

