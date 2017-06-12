#!/usr/bin/env bash

sudo cp /home/posda/posdatools/systemd/service-files/*.service /etc/systemd/system/
sudo systemctl daemon-reload

sudo systemctl enable posda --now
sudo systemctl enable posda-backlog --now
sudo systemctl enable posda-file-process --now

