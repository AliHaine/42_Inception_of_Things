install:
	sh ./scripts/install.sh
	
run:
	sh ./scripts/run.sh
	
down:
	k3d cluster delete maincluster
	
all: install run
	 @echo "Starting ..."