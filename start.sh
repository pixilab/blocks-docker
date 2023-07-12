#!/bin/bash

# Start codemeter and add license server address.
service codemeter start
if [ -n "$LICENSE_SERVER" ] ; then
	cmu --add-server $LICENSE_SERVER
fi

# Create the "blocks" user if $USERID does not exist.
if ! id $USERID > /dev/null 2>&1 ; then
	useradd blocks -u $USERID --user-group
fi

# Download and install Blocks if not already installed.
if [ ! -f /home/blocks/PIXILAN.jar ]; then
	wget https://pixilab.se/outgoing/blocks/PIXILAB_Blocks_Linux.tar.gz \
	&& tar -xzf PIXILAB_Blocks_Linux.tar.gz -C /home/blocks/ \
	&& rm PIXILAB_Blocks_Linux.tar.gz
	chown -R blocks /home/blocks
	chgrp -R blocks /home/blocks
fi

BLOCKS_VM_OPTIONS="-noverify \
	--illegal-access=permit \
	-Dfile.encoding=UTF-8 \
	-Xmx2G \
	-XX:+HeapDumpOnOutOfMemoryError \
	-XX:HeapDumpPath='/home/blocks/PIXILAB-Blocks-root/logs'"

# Start Blocks as the "blocks" user. Use "exec" to allow for graceful exit.
exec su -c "/usr/bin/java \
    -Djava.library.path=/home/blocks/native:/usr/java/packages/lib:/usr/lib64:/lib64:/lib:/usr/lib \
    ${BLOCKS_VM_OPTIONS} \
    -jar /home/blocks/PIXILAN.jar" -s /bin/bash blocks
