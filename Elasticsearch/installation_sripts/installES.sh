#!/bin/bash
sudo yum install -y java-1.8.0-openjdk.x86_64
java -version
sudo wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.2-x86_64.rpm
sudo rpm -ivh elasticsearch-7.5.2-x86_64.rpm
sudo service elasticsearch start
sleep 10
sudo service elasticsearch status

