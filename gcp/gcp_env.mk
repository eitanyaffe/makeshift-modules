# run image locally with X11
denv:
	docker run --rm -it --privileged \
	       -v /tmp/.X11-unix:/tmp/.X11-unix \
	       -e DISPLAY=host.docker.internal:0 \
	       -e MAKESHIFT_ROOT=/makeshift \
	       -v /Users/eitany/work/makeshift:/makeshift \
	       -e GOOGLE_APPLICATION_CREDENTIALS=/makeshift/key.json \
	       -e SENDGRID_API_KEY=$(SENDGRID_API_KEY) \
	       -e BOTO_CONFIG=/makeshift/.boto \
	       -e USER=$(USER) \
	       -v /tmp:/tmp \
	       -v /var/run/docker.sock:/var/run/docker.sock \
	       -w /makeshift/$(GCP_PIPELINE_RELATIVE_DIR) \
	       $(GCP_GCR_IMAGE_PATH) 'bash'

# run in VM
venv:
	cat $(MAKESHIFT_ROOT)/key.json | sudo docker login -u _json_key --password-stdin https://gcr.io
	sudo docker run --rm -it --privileged \
	       -v /tmp/.X11-unix:/tmp/.X11-unix \
	       -e DISPLAY=host.docker.internal:0 \
	       -e MAKESHIFT_ROOT=/makeshift \
	       -v /makeshift:/makeshift \
	       -e GOOGLE_APPLICATION_CREDENTIALS=/makeshift/key.json \
	       -e USER=$(USER) \
	       -e BOTO_CONFIG=/makeshift/.boto \
	       -v /var/run/docker.sock:/var/run/docker.sock \
	       -w /makeshift/$(GCP_PIPELINE_RELATIVE_DIR) \
	       $(GCP_GCR_IMAGE_PATH) 'bash'

# makeshift mounted through bucket
denv_bucket:
	docker run --rm -it --privileged \
	       -v /tmp/.X11-unix:/tmp/.X11-unix \
	       -e DISPLAY=host.docker.internal:0 \
	       -e MAKESHIFT_BUCKET_BASE=$(GCP_MAKESHIFT_BUCKET_BASE) \
	       -e MAKESHIFT_ROOT=/makeshift \
	       -e GOOGLE_APPLICATION_CREDENTIALS=/makeshift/key.json \
	       -e BOTO_CONFIG=/makeshift/.boto \
	       -v /Users/eitany/work/makeshift:/makeshift_local \
	       -v /var/run/docker.sock:/var/run/docker.sock \
	       $(GCR_IMAGE_PATH) /bin/bash

vm_no_container:
	gcloud compute \
	  --project=$(GCP_PROJECT_ID) \
	  instances create $(VGCP_M_NAME) \
	  --zone=$(GCP_ZONE) \
	  --machine-type=$(GCP_MACHINE_TYPE) \
	  --metadata=google-logging-enabled=true \
	  --scopes=https://www.googleapis.com/auth/cloud-platform \
	  --network-tier=STANDARD \
	  --image-project=$(GCP_PROJECT_ID) \
	  --image=$(GCP_VM_IMAGE_NAME) \
	  --enable-display-device

vm:
	gcloud compute \
	  --project=$(GCP_PROJECT_ID) \
	  instances create-with-container $(GCP_VM_NAME) \
	  --zone=$(GCP_ZONE) \
	  --machine-type=$(GCP_MACHINE_TYPE) \
	  --network-tier=STANDARD \
	  --metadata=google-logging-enabled=true \
	  --maintenance-policy=MIGRATE \
	  --scopes=https://www.googleapis.com/auth/cloud-platform \
	  --image-family=cos-stable \
	  --image-project=cos-cloud \
	  --boot-disk-size=10GB \
	  --boot-disk-type=pd-standard \
	  --boot-disk-device-name=$(GCP_VM_NAME) \
	  --container-image=$(GCP_GCR_IMAGE_PATH) \
	  --container-privileged \
	  --container-mount-host-path=host-path=/var/run/docker.sock,mount-path=/var/run/docker.sock \
	  --container-env="MAKESHIFT_BUCKET_BASE=$(GCP_MAKESHIFT_BUCKET_BASE),MAKESHIFT_ROOT=/makeshift" \
	  --container-restart-policy=on-failure \
	  --container-stdin \
	  --container-tty

# must run in container
# gcsfuse --implicit-dirs eitany-makeshift-bucket /makeshift

vm_update:
	gcloud compute \
	  --project=$(GCP_PROJECT_ID) instances update-container \
	  $(VM_NAME) \
	  --zone=$(ZONE) \
	  --container-image=$(GCP_GCR_IMAGE_PATH) \
	  --container-privileged \
	  --container-env="MAKESHIFT_BUCKET_BASE=$(GCP_MAKESHIFT_BUCKET_BASE),MAKESHIFT_ROOT=/makeshift" \
	  --container-mount-host-path=host-path=/var/run/docker.sock,mount-path=/var/run/docker.sock \
	  --container-restart-policy=on-failure \
	  --container-tty

vm_kill:
	gcloud compute instances delete $(GCP_VM_NAME) --zone=$(GCP_ZONE) --delete-disks all

vm_ssh:
	gcloud compute ssh \
		$(GCP_VM_NAME) \
		--zone=$(GCP_ZONE)

ssh:
	gcloud compute ssh \
		$(GCP_VM_NAME) \
		--zone=$(GCP_ZONE)

list:
	gcloud compute instances list
