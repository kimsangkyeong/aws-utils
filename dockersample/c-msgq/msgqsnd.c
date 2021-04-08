#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/ipc.h>
#include <sys/types.h>
#include <sys/msg.h>
#include <string.h>
#include <errno.h>
#include "msg_data.h"

void printMsgInfo(int msgqid){
    struct msqid_ds m_stat;

    printf("== messege queue info start ==\n");
    if(msgctl(msgqid,IPC_STAT,&m_stat)==-1){
        printf("msgctl failed : %d, %s\n", errno, strerror(errno));
        exit(0);
    }
    printf(" message queue info \n");
    printf(" msg_qnum : %d\n",m_stat.msg_qnum);
    printf(" msg_lspid : %d\n",m_stat.msg_lspid);
    printf(" msg_ctime : %d\n",m_stat.msg_ctime);
    printf(" msg_stime : %d\n",m_stat.msg_stime);

    printf("== messege queue info end ==\n");
}

int main()
{
    /* time variable */
    time_t rawtime;
    struct tm *ptm = NULL;

    /* msgqueue variable  */
    key_t  key=12345;
    int    msgqid;
    struct message msg;

    rawtime = time(NULL);
    ptm = localtime(&rawtime);
    printf("\n= send program ! - %d/%d %02d:%02d:%02d \n", 
                  ptm->tm_mon+1, ptm->tm_mday, ptm->tm_hour, ptm->tm_min, ptm->tm_sec);
    fflush(stdout);

    /* msgq struct info */
    msg.msg_type=1;
    msg.data.seconds=rawtime;
    sprintf(msg.data.times,"%02d시%02d분%02d초", ptm->tm_hour, ptm->tm_min, ptm->tm_sec);

    //msgqid를 얻어옴.
    if((msgqid=msgget(key,IPC_CREAT|0666))==-1){
        printf("msgget failed : %d, %s\n", errno, strerror(errno));
        exit(0);
    }

    //메시지를 보낸다.
    if(msgsnd(msgqid,&msg,sizeof(struct real_data),0)==-1){
        printf("msgsnd failed : %d, %s\n", errno, strerror(errno));
        exit(0);
    }

    printf("message sent\n");

    //메시지 보낸 후  msgqid_ds를 한번 보자.
    printMsgInfo(msgqid);

    return 0;
}
