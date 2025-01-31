FROM alpine:latest AS build

ENV PYTHONDONTWRITEBYTECODE=1 \
PYTHONUNBUFFERED=1 

RUN apk add python3 
RUN python -m venv /opt/.venv 
RUN source /opt/.venv/bin/activate \
&& python -m pip install ffxiahbot --no-cache-dir
ADD contrib/settings/items.csv /opt/.config/items.csv
ADD contrib/scripts/start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

FROM alpine:latest

# Name that appears on AH when buying and selling
ENV AUCTIONEER=M.H.M.U. \ 
# seconds between buying
BUYING=30 \
# seconds between selling
RESTOCK=1800 \
# Only buy items a fraction of the time?
PARTBUY=false  \
# Only sell items a fraction of the time?
PARTSELL=false  \
# sql hostname
HOSTNAME=host.docker.internal \
# sql database
DB=xidb \
USER=root \
PASS=root \
PORT=3306 \
# fail on SQL database errors?
FAIL=true \
PYTHONDONTWRITEBYTECODE=1 \
PYTHONUNBUFFERED=1 

COPY --from=build /opt /opt
RUN apk add python3 --no-cache \
# Create the config.yaml file using environment variables
&& echo "---\n\
# ah\n\
name: ${AUCTIONEER}  # Name that appears on AH when buying and selling\n\
tick: ${BUYING}  # seconds between buying\n\
restock: ${RESTOCK}  # seconds between selling\n\
use_buying_rates: ${PARTBUY}  # Only buy items a fraction of the time?\n\
use_selling_rates: ${PARTSELL}  # Only sell items a fraction of the time?\n\
\n\
# sql\n\
hostname: ${HOSTNAME}  # SQL parameter\n\
database: ${DB}  # SQL parameter\n\
username: ${USER}  # SQL parameter\n\
password: ${PASS}  # SQL parameter\n\
port: ${PORT}  # SQL parameter\n\
fail: ${FAIL}  # fail on SQL database errors?\n" > /opt/.config/config.yaml

ENTRYPOINT [ "/opt/start.sh" ]