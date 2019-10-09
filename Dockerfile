FROM alpine:latest
# echo -e "https://mirrors.ustc.edu.cn/alpine/latest-stable/main\nhttps://mirrors.ustc.edu.cn/alpine/latest-stable/community" > /etc/apk/repositories && \
RUN apk --update --no-cache add fuse alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev && \
	wget -qO- https://github.com/aliyun/ossfs/archive/master.tar.gz | tar xz          			&& \
	cd ossfs-master 																 			&& \
	./autogen.sh										     									&& \
	./configure 																	 			&& \
	make																						&& \
	make install			 																	

FROM erichough/nfs-server:latest
LABEL maintainer="hayond@qq.com"
COPY --from=0 /usr/local/bin/ossfs /usr/local/bin/ossfs
# echo -e "https://mirrors.ustc.edu.cn/alpine/latest-stable/main\nhttps://mirrors.ustc.edu.cn/alpine/latest-stable/community" > /etc/apk/repositories && \
ARG OSSFS_PATH /ossfs

RUN apk --update --no-cache add fuse curl libxml2 libstdc++										&& \
	mkdir ${OSSFS_PATH}                 					

ENV OSSFS_PATH ${OSSFS_PATH}
ENV BUCKET ossfs-nfs
ENV ENDPOINT_URL ossfs-nfs.oss-cn-hangzhou-internal.aliyuncs.com
ENV ACCESS_KEY access_key
ENV ACCESS_SECRET access_secret
ENV NFS_EXPORT_0 $OSSFS_PATH                  *(rw,no_root_squash)

CMD ossfs $BUCKET $OSSFS_PATH -ourl=$ENDPOINT_URL 												 ; \
	echo $BUCKET:$ACCESS_KEY:$ACCESS_SECRET > /etc/passwd-ossfs 								&& \
	entrypoint.sh 			

