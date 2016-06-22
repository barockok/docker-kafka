FROM barockok/confluent
ADD download-ruby-helper.sh /usr/bin/download-ruby-helper.sh
ADD start-service.sh /usr/bin/start-service.sh
RUN download-ruby-helper.sh > /ruby-processcli-helper.rb
RUN rm /usr/bin/download-ruby-helper.sh
EXPOSE 9091
CMD ["start-service.sh"]