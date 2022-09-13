# IcebergCRX

This prototype aims to provide training for incident responders in a highly realistic scenario making use of the simulation component of the digital twin of an industrial filling plant. 
In the scenario, an attacker has gained access to the industrial system and performs a Man-In-The-Middle attack to disrupt the filling operations. 

The components of the industrial system thereby produce log data which are forwarded to a SIEM system. 

Completing the tasks of the cyber range, a trainee gains knowledge about the selected attacks on the industrial system and how to respond these attacks. This is achieved by investigating the corrensponding alarms and events in the SIEM and taking appropriate action to contain, erdicated and finally recover from the attack.


**User interface of the cyber range:**


## Conceptual overview of the cyber range design
The cyber range consists for four main building blocks: a **Virutal Filling Plant**, a **SIEM-based SOC**, **Learning Management System (LMS)**, and a **REST-API**.


## Architecture of the prototype
The cyber range is contained within a Ubuntu-based Virtual Machine.

Two of the building blocks are realized through a micro-service architecture based on **Docker Containers**: 

- The **Virutal Filling Plant**, in turn, consists of three components contained in one Docker container:
    - a simulation of a [Digital Twin](./src) which is tailored to the needs of the cyber range scenario. It is implemented with [MiniCPS](https://github.com/scy-phy/minicps), an academic framework for simulating cyber-physical systems which builds upon [Mininet](http://mininet.org). 
    - simulated attacks based on two common tools used for cyberattacks: [Ettercap](https://www.ettercap-project.org/) and [hping](http://www.hping.org/). 
    - an Intrusion Dectection System (IDS) implemented with [Scapy](https://scapy.net/).
- The **SIEM-based SOC** system is realized with [Dsiem](https://www.dsiem.org/), which builds upon [Filebeat, Elasticsearch, Logstash and Kibana](https://www.elastic.co/). and comprises five Docker containers.

The remaining two building blocks run directly on the Ubuntu-based Virtual Machine.


- The **Learning Management System (LMS)** is implemented with the JavaScript Framework [Vue.js](https://vuejs.org/). The respective source code is stored in the [frontendCyberrange](https://github.com/DigitalTwinSocCyberrange/frontendCyberrange) repository of the project.
- A **[REST-API]((https://github.com/DigitalTwinSocCyberrange/DigitalTwinCyberrange/tree/main/src/pyrest))** implemented with [Flask](https://flask.palletsprojects.com/en/1.1.x/) connects the LMS, the Digital Twin and the SIEM-System
- The user data is stored in a Firestore collection, described in detail [here](#user-data-management)

 <p align="center">
  <img src="https://user-images.githubusercontent.com/56884203/112836327-bb7fa480-909a-11eb-85bc-8307505d52f4.png" />
</p>

## Installation (for Ubuntu 20.04)

1. Install [Docker](https://docs.docker.com/engine/install/ubuntu/) and [Docker-Compose](https://docs.docker.com/compose/install/) as described in the respective docs

2. create a joint directory and clone the required repositories:
```bash
mkdir cyberrange && \
cd cyberrange && \
git clone https://github.com/TARGETframework/Backend_IcebergCRX.git && \
git clone https://github.com/TARGETframework/Frontend_IcebergCRX.git
 ```
 3. **Install dependencies for deployment of the front end:**
```bash
cd Frontend_IcebergCRX && \
bash setup_frontend.sh
 ```

4. **Install dependencies for deployment of the Flask-Api:**
```bash
cd Backend_IcebergCRX/src/host_vm && \
bash setup_cyberrange_host.sh
 ```
5. **Setup and start the cyber range**: This will start the microservice-infrastructure (Elasticsearch, Filebeat, Logstash, Kibana, Dsiem and Digital Twin), the cyber range front end (running on port 7080) and the API that connects both
```bash
cd deployments/docker && \
bash init_cyberrange.sh
 ```
6. Enter the ip address or hostname where the cyber range should be deployed. Usually, this is either the default ip address of the maschine or localhost. 199.999.9.99 is used as an example ip address here.

```bash
Enter the Hostname or IP Address where the cyber range will be deployed: 199.999.9.99
```
 7. Access the cyber range on port 7080: **ht<span>tp://</span>199.999.9.99:7080**. To get an idea of the prototype, you can use the demo user (without user data management) **ID=127**
 <p align="center">
  <img src="https://user-images.githubusercontent.com/56884203/112821652-3e96ff80-9087-11eb-805f-aee2533ac3d7.png" width="500" />
</p>

 8. If you want to conduct a cyber range training with multiple participants and use the scoreboard, please proceed with [User Data Management](#user-data-management)
## Shutdown
To shut down the infrastructure you can either the use the API-functionality **ht<span>tp://</span>199.999.9.99:9090/stop_cr** or run the shutdown script:
 
 ```bash
cd deployments/docker && \
bash docker_stop.sh
 ```

## Startup
To restart the infrastructure you can either the use the API-functionality **ht<span>tp://</span>199.999.9.99:9090/start_cr** or run the startup script:
 
 ```bash
cd deployments/docker && \
bash docker_start.sh
 ```

## User Data Management
User data management enables the gamification aspect of the cyber range with a score board displaying the scores of the other players in order to motivate the trainees to engage well in the training. 
 <p align="center">
  <img src="https://user-images.githubusercontent.com/56884203/112821702-4fe00c00-9087-11eb-82bd-ca8c09e51f73.png" width="300" />
</p>

Furthermore, storing the progress of each user in a central database enables the trainer to monitor the conduction of the training and facilitates to evaluate the training after conduction. 
Every trainee initially needs to be assigned the following attributes.

 - **userID**: randomly chosen ID to log into the cyber range, primary key of the Firestore Collection
 - **username**: each userID is assigned a username. This is displayed on the scoreboard
 - **round**: refers to the round (or the group) of conduction of the cyber range training. The trainee will only see the scores of the players that are playing in the same round as he or she does
 
While taking part in the cyber range training the following data is recorded:

- points: current score of the trainee (out of a maximum score of 101)
- level: number of tasks the trainee has completed
- startTime: timestamp when the trainee first logged in
- taskTimes: time the trainee took to solve a task

## Deploy repository for user registration and VM assignment:


### Import and export of user data with .csv files
1. Create a Service Account on Firebase. This can be done on the Firebase Dashboard via Settings -> Service Account -> "Generate Private Key" as described [here]( https://firebase.google.com/docs/admin/setup#python)
2. Replace the file [serviceAccount.json](https://github.com/TARGETframework/Frontend_IcebergCRX/blob/main/userDataScripts/serviceAccount.json) with your created key (also naming it serviceAccount.json)
3. Replace the sample user data in [userdata.csv](https://github.com/TARGETframework/Frontend_IcebergCRX/blob/main/userDataScripts/usernames.csv) with your user data sets
4. Run import script:
```bash
cd Frontend_IcebergCRX/userDataScripts && \
python3 importFromCsv.py
 ```
*To export user data (points, level, times) after the training, run:*
 
 ```bash
cd Frontend_IcebergCRX/userDataScripts && \
python3 exportToCsv.py
 ```

