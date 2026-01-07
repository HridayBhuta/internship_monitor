# Internship Monitor

A lightweight Bash-based automation pipeline that monitors job postings on company career pages, detects daily changes, and logs both current openings and new updates.

This project is designed to run on Linux or WSL and uses standard Unix tools (`curl`, `grep`, `comm`, `cron`).

## Features

- Tracks job postings from multiple company career pages
- Detects **new** and **removed** job roles daily
- Excludes research-focused positions (e.g. PhD, Postdoc, Research Scientist)
- Maintains:
  - a full snapshot of current jobs
  - a change log showing differences from the previous day
- Fully automated via `cron`


## Project Structure

```
job-tracker/
├── run.sh
├── fetch.sh
├── build_logs.sh
├── url.example.txt # Example input file (user copies to urls.txt)
├── cron/
│ └── cron.example
├── jobs/
│ ├── today/
│ └── yesterday/
├── logs/
│ ├── current_jobs.log
│ └── changes.log
├── .gitignore
└── README.md
```


## Requirements

- Linux or **WSL (Ubuntu recommended)**
- Bash
- `shot-scraper`
- `curl`
- `grep`, `sed`, `sort`, `comm`
- `cron` (optional, for automation)

Install missing tools if needed:
```bash
sudo apt update
sudo apt install curl cron -y
pip install shot-scraper
```

## Setup
### Clone the repository
```bash
git clone https://github.com/your-username/job-tracker.git
cd internship_monitor
```

### Create your URLs file
```bash
cp url.example.txt urls.txt
```

### Make scripts executable
```bash
chmod +x run.sh fetch.sh build_logs.sh
```

### Usage
Run the entire pipeline manually:

```bash
./run.sh
```

After execution:

`logs/current_jobs.log` → All currently open job roles

`logs/changes.log` → New and removed roles since last run

### Automating with Cron (Optional)
Start cron (WSL / Linux)

```bash
sudo service cron start
crontab -e
```

Follow the example given in `cron/cron.example`. That will make the script run everyday automatically at 9 am.

## License
MIT License