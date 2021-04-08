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

    printf("** messege queue info start **\n");
    if(msgctl(msgqid,IPC_STAT,&m_stat)==-1){
        printf("msgctl failed : %d, %s\n", errno, strerror(errno));
        exit(0);
    }
    printf(" message queue info \n");
    printf(" msg_qnum : %d\n",m_stat.msg_qnum);
    printf(" msg_lrpid : %d\n",m_stat.msg_lrpid);
    printf(" msg_ctime : %d\n",m_stat.msg_ctime);
    printf(" msg_stime : %d\n",m_stat.msg_stime);
    printf(" msg_rtime : %d\n",m_stat.msg_rtime);

    printf("** messege queue info end ** \n");
    fflush(stdout);
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
    printf("\n* receive program ! - %d/%d %02d:%02d:%02d \n", 
                  ptm->tm_mon+1, ptm->tm_mday, ptm->tm_hour, ptm->tm_min, ptm->tm_sec);
    fflush(stdout);

    //msgqid를 얻어옴.
    if((msgqid=msgget(key,IPC_CREAT|0666))==-1){
        printf("msgget failed : %d, %s\n", errno, strerror(errno));
        exit(0);
    }

    //메시지 받기
    if(msgrcv(msgqid,&msg,sizeof(struct real_data),0,IPC_NOWAIT)==-1){
        printf("msgrcv failed : %d, %s\n", errno, strerror(errno)); 
                                         /* info :  <asm-generic/errno.h> - ENOMSG 42 */
        exit(0);
    }
  
    printf("receive data - seconds : %d, times :%s\n",msg.data.seconds,msg.data.times);
    fflush(stdout);

    //메시지 수신후  msgquid_ds 조회
    printMsgInfo(msgqid);

    return 0;
}
