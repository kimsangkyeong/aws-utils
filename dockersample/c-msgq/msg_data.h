/* message data */
struct real_data{
        time_t seconds;
        char   times[16];
};

/* messsage queue header */
struct message{
        long msg_type;
        struct real_data data;
};
